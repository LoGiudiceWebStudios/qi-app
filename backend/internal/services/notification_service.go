package services

import (
	"context"
	"fmt"
	"log"
	"strings"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/robfig/cron/v3"
	"google.golang.org/api/option"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

var FCMClient *messaging.Client
var AppCron *cron.Cron

// InitFirebase inizializza il client FCM.
func InitFirebase() {
	ctx := context.Background()
	// Specifichiamo il path del file scaricato
	opt := option.WithCredentialsFile("serviceAccountKey.json")

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Fatalf("Errore durante l'inizializzazione di Firebase App: %v\n", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		log.Fatalf("Errore durante l'inizializzazione del client FCM: %v\n", err)
	}

	FCMClient = client
	fmt.Println("Firebase Cloud Messaging (FCM) inizializzato con successo!")
}

// SendMulticastNotification invia una notifica push a una lista di token.
func SendMulticastNotification(title, body string, tokens []string) error {
	if FCMClient == nil {
		return fmt.Errorf("FCMClient non inizializzato")
	}
	if len(tokens) == 0 {
		return nil // Nessun utente a cui inviare
	}

	message := &messaging.MulticastMessage{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				Sound: "default",
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: "default",
				},
			},
			Headers: map[string]string{
				"apns-priority": "10",
			},
		},
		Tokens: tokens,
	}

	ctx := context.Background()
	response, err := FCMClient.SendEachForMulticast(ctx, message)
	if err != nil {
		return err
	}
	fmt.Printf("Notifiche inviate: successi %d, fallimenti %d\n", response.SuccessCount, response.FailureCount)
	return nil
}

// StartCronJobs avvia le notifiche programmate (es. ogni martedi alle 12)
func StartCronJobs() {
	if AppCron != nil {
		AppCron.Stop()
	}
	AppCron = cron.New()

	ReloadSchedules()

	AppCron.Start()
	fmt.Println("Cron Jobs avviati con successo!")
}

// ReloadSchedules ricarica le notifiche dal database
func ReloadSchedules() {
	if AppCron != nil {
		AppCron.Stop()
		AppCron = cron.New()
	} else {
		AppCron = cron.New()
	}

	var notifications []models.ScheduledNotification
	database.DB.Find(&notifications)

	for _, n := range notifications {
		scheduleLocalNotification(n)
	}
	AppCron.Start()
}

func scheduleLocalNotification(n models.ScheduledNotification) {
	parts := strings.Split(n.Time, ":")
	if len(parts) != 2 {
		return
	}
	hour := parts[0]
	min := parts[1]
	cronSpec := fmt.Sprintf("%s %s * * %d", min, hour, n.DayOfWeek)

	AppCron.AddFunc(cronSpec, func() {
		fmt.Printf("Esecuzione Cron Programmato: Notifica '%s' alle %s (Giorno %d)\n", n.Title, n.Time, n.DayOfWeek)

		var users []models.User
		database.DB.Where("fcm_token IS NOT NULL AND fcm_token != ?", "").Find(&users)

		var tokens []string
		for _, u := range users {
			tokens = append(tokens, u.FCMToken)
		}

		if len(tokens) > 0 {
			SendMulticastNotification(n.Title, n.Message, tokens)
		}
	})
}
