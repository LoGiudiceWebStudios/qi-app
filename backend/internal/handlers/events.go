package handlers

import (
	"net/http"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/eventvisibility"
	"qi-backend/internal/models"
)

func GetEvents(c *gin.Context) {
	now := time.Now()
	var events []models.Event
	eventCutoff := now.In(time.Local).Add(-12 * time.Hour)
	eventCutoff = time.Date(eventCutoff.Year(), eventCutoff.Month(), eventCutoff.Day(), 0, 0, 0, 0, eventCutoff.Location())
	if err := database.DB.Where("data_evento >= ? OR ricorrenza_giorno >= 0", eventCutoff).Order("data_evento asc").Find(&events).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nel recupero degli eventi"})
		return
	}

	filtered := make([]models.Event, 0, len(events))
	for _, event := range events {
		if eventvisibility.IsActive(event, now) {
			if event.RicorrenzaGiorno >= 0 {
				event.DataEvento = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
			}
			filtered = append(filtered, event)
		}
	}

	// Normalizza i path delle immagini per chi usa vecchi dati
	for i := range filtered {
		if len(filtered[i].ImmagineURL) > 0 {
			filtered[i].ImmagineURL = filepath.ToSlash(filtered[i].ImmagineURL)
			if filtered[i].ImmagineURL[0] == '/' {
				filtered[i].ImmagineURL = filtered[i].ImmagineURL[1:]
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{"data": filtered})
}

// Inserisci api admin events
func CreateEvent(c *gin.Context) {
	var event models.Event
	if err := c.ShouldBindJSON(&event); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := database.DB.Create(&event).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nella creazione dell'evento"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": event})
}
