package admin

import (
	"log"
	"net/http"

	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type DashboardHandler struct {
}

func NewDashboardHandler() *DashboardHandler {
	return &DashboardHandler{}
}

func (h *DashboardHandler) RenderDashboard(c *gin.Context) {
	// Variabili impostazioni
	var forcedStatus models.Setting
	if err := database.DB.Where("key = ?", "forced_status").First(&forcedStatus).Error; err != nil { database.DB.Create(&models.Setting{Key: "forced_status", Value: "auto"}) }

	var closingTime models.Setting
	if err := database.DB.Where("key = ?", "closing_time").First(&closingTime).Error; err != nil { database.DB.Create(&models.Setting{Key: "closing_time", Value: "02:00"}) }

	var openingTime models.Setting
	if err := database.DB.Where("key = ?", "opening_time").First(&openingTime).Error; err != nil { database.DB.Create(&models.Setting{Key: "opening_time", Value: "18:00"}) }

	data := gin.H{
		"Title":        "Dashboard Qi App",
		"TotalEvents":  14,
		"TotalOffers":  5,
		"ForcedStatus": forcedStatus.Value,
		"ClosingTime":  closingTime.Value,
		"OpeningTime":  openingTime.Value,
	}

	c.HTML(http.StatusOK, "dashboard.html", data)
}

func (h *DashboardHandler) UpdateSettings(c *gin.Context) {
	forcedStatus := c.PostForm("forced_status")
	closingTime := c.PostForm("closing_time")
	openingTime := c.PostForm("opening_time")

	if forcedStatus != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "forced_status").Update("value", forcedStatus)
	}
	if closingTime != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "closing_time").Update("value", closingTime)
	}
	if openingTime != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "opening_time").Update("value", openingTime)
	}

	log.Println("Impostazioni orari aggiornate:", forcedStatus, closingTime, openingTime)

	c.Redirect(http.StatusFound, "/admin")
}
