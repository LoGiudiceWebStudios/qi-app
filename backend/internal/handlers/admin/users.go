package admin

import (
	"net/http"

	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type UsersHandler struct{}

func NewUsersHandler() *UsersHandler {
	return &UsersHandler{}
}

func (h *UsersHandler) HandleIndex(c *gin.Context) {
	var users []models.User
	if err := database.DB.Where("ruolo = ?", "user").Order("id desc").Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nel caricamento degli utenti"})
		return
	}

	c.HTML(http.StatusOK, "users.html", gin.H{
		"Title": "Gestione Utenti",
		"Users": users,
	})
}
