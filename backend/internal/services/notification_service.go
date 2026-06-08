package services

import (
"context"
"fmt"
"log"
"strconv"

firebase "firebase.google.com/go/v4"
"firebase.google.com/go/v4/messaging"
"github.com/robfig/cron/v3"
"google.golang.org/api/option"

"qi-backend/internal/database"
"qi-backend/internal/models"
)

var FCMClient *messaging.Client
var AppCron *cron.Cron

func InitFirebase() {
ctx := context.Background()
opt := option.WithCredentialsFile("serviceAccountKey.json")

app, err := firebase.NewApp(ctx, nil, opt)
if err != nil {
log.Fatalf("Errore durante l'inizializzazione di Firebase App: %v", err)
}

client, err := app.Messaging(ctx)
if err != nil {
log.Fatalf("Errore durante l'inizializzazione del client FCM: %v", err)
}

FCMClient = client
fmt.Println("Firebase Cloud Messaging (FCM) inizializzato con successo!")
}

func SendMulticastNotification(title, body string, tokens []string) error {
if FCMClient == nil {
return fmt.Errorf("FCMClient non inizializzato")
}
if len(tokens) == 0 {
return nil
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

func StartCronJobs() {
if AppCron == nil {
AppCron = cron.New()
AppCron.Start()
}
ReloadSchedules()
fmt.Println("Cron Jobs avviati con successo!")
}

func ReloadSchedules() {
if AppCron != nil {
for _, entry := range AppCron.Entries() {
AppCron.Remove(entry.ID)
}

var schedules []models.ScheduledNotification
database.DB.Find(&schedules)

for _, s := range schedules {
h, _ := strconv.Atoi(s.Time[:2])
m, _ := strconv.Atoi(s.Time[3:])
cronExpr := fmt.Sprintf("%d %d * * %d", m, h, s.DayOfWeek)
title := s.Title
message := s.Message

AppCron.AddFunc(cronExpr, func() {
SendNotificationToAll(title, message)
})
}
}
}

func SendNotificationToAll(title, message string) {
var users []models.User
database.DB.Where("fcm_token != '").Find(&users)
var tokens []string
for _, u := range users {
tokens = append(tokens, u.FCMToken)
}
if len(tokens) > 0 {
SendMulticastNotification(title, message, tokens)
}
}
