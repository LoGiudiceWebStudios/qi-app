package handlers

import (
	"net/http"
	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"github.com/gin-gonic/gin"
)

func GetRewards(c *gin.Context) {
	var rewards []models.Reward
	database.DB.Find(&rewards)
	c.JSON(http.StatusOK, gin.H{"success": true, "data": rewards})
}
