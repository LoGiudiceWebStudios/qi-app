package admin

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
	"qi-backend/internal/services"
)

type EventsHandler struct{}

func NewEventsHandler() *EventsHandler {
	return &EventsHandler{}
}

func (h *EventsHandler) RenderEvents(c *gin.Context) {
	var events []models.Event
	database.DB.Order("data_evento desc").Find(&events)

	// Fix path slashes per eventi vecchi rimasti nel database
	for i := range events {
		if len(events[i].ImmagineURL) > 0 {
			events[i].ImmagineURL = filepath.ToSlash(events[i].ImmagineURL)
			if !strings.HasPrefix(events[i].ImmagineURL, "http") {
				if events[i].ImmagineURL[0] != '/' {
					events[i].ImmagineURL = "/" + events[i].ImmagineURL
				}
			}
		}
	}

	data := gin.H{
		"Title":  "Gestione Eventi",
		"Events": events,
	}

	c.HTML(http.StatusOK, "events.html", data)
}

func (h *EventsHandler) RenderNewEvent(c *gin.Context) {
	data := gin.H{
		"Title": "Crea Nuovo Evento",
	}
	c.HTML(http.StatusOK, "event_new.html", data)
}

func (h *EventsHandler) CreateEvent(c *gin.Context) {
	titolo := c.PostForm("titolo")
	descrizione := c.PostForm("descrizione")
	dataEventoStr := c.PostForm("data_evento")
	oraEvento := c.PostForm("ora_evento")
	luogo := c.PostForm("luogo")

	dataEvento, _ := time.Parse("2006-01-02", dataEventoStr)

	// Gestione salvataggio Immagine
	var immagineURL string
	file, err := c.FormFile("immagine")
	if err == nil {
		// Crea la cartella "uploads/events" se non esiste
		os.MkdirAll("uploads/events", os.ModePerm)

		// Genera un nome file univoco
		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), filepath.Base(file.Filename))
		outPath := filepath.Join("uploads/events", filename)

		// Salva il file compresso
		if finalPath, err := services.CompressAndSaveImage(file, outPath); err == nil {
			// Sostituiamo backslash convertiti e nome finale (es. .jpg) per l'URL
			imageFinalUrl := filepath.ToSlash(finalPath)
			immagineURL = "/" + imageFinalUrl // Lo salviamo come stringa da servire al frontend
		}
	}

	evento := models.Event{
		Titolo:      titolo,
		Descrizione: descrizione,
		DataEvento:  dataEvento,
		Ora:         oraEvento,
		Luogo:       luogo,
		ImmagineURL: immagineURL,
	}

	if err := database.DB.Create(&evento).Error; err == nil {
		// Invia notifica agli user
		var users []models.User
		database.DB.Where("fcm_token != ''").Find(&users)
		var tokens []string
		for _, u := range users {
			tokens = append(tokens, u.FCMToken)
		}
		services.SendMulticastNotification("Nuovo Evento: "+titolo, "Scopri il nuovo evento: "+titolo, tokens)

		c.Redirect(http.StatusFound, "/admin/events")
		return
	}

	// In caso di errore
	c.String(http.StatusInternalServerError, "Errore salvataggio evento")
}

func (h *EventsHandler) DeleteEvent(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Delete(&models.Event{}, id).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore durante l'eliminazione dell'evento")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/events")
}
