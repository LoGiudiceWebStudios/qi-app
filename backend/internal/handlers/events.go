package handlers

import (
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

func GetEvents(c *gin.Context) {
	var events []models.Event
	if err := database.DB.Find(&events).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nel recupero degli eventi"})
		return
	}

	// Normalizza i path delle immagini per chi usa vecchi dati
	for i := range events {
		if len(events[i].ImmagineURL) > 0 {
			events[i].ImmagineURL = filepath.ToSlash(events[i].ImmagineURL)
			if events[i].ImmagineURL[0] == '/' {
				events[i].ImmagineURL = events[i].ImmagineURL[1:]
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{"data": events})
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
