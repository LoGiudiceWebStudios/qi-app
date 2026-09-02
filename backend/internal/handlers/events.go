package handlers

import (
	"net/http"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

func eventMatchesRecurrence(event models.Event, now time.Time) bool {
	if event.RicorrenzaGiorno < 0 {
		return true
	}
	return int(now.Weekday()) == event.RicorrenzaGiorno
}

func GetEvents(c *gin.Context) {
	now := time.Now()
	var events []models.Event
	if err := database.DB.Where("data_evento >= ?", now.Add(-12*time.Hour)).Order("data_evento asc").Find(&events).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nel recupero degli eventi"})
		return
	}

	filtered := make([]models.Event, 0, len(events))
	for _, event := range events {
		if eventMatchesRecurrence(event, now) {
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
