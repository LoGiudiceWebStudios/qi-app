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
	if err := database.DB.Where("key = ?", "forced_status").First(&forcedStatus).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "forced_status", Value: "auto"})
	}

	var closingTime models.Setting
	if err := database.DB.Where("key = ?", "closing_time").First(&closingTime).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "closing_time", Value: "02:00"})
	}

	var openingTime models.Setting
	if err := database.DB.Where("key = ?", "opening_time").First(&openingTime).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "opening_time", Value: "18:00"})
	}

	var forcedKitchenStatus models.Setting
	if err := database.DB.Where("key = ?", "forced_kitchen_status").First(&forcedKitchenStatus).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "forced_kitchen_status", Value: "auto"})
	}

	var kitchenClosingTime models.Setting
	if err := database.DB.Where("key = ?", "kitchen_closing_time").First(&kitchenClosingTime).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "kitchen_closing_time", Value: "23:00"})
	}

	var kitchenOpeningTime models.Setting
	if err := database.DB.Where("key = ?", "kitchen_opening_time").First(&kitchenOpeningTime).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "kitchen_opening_time", Value: "19:00"})
	}

	data := gin.H{
		"Title":               "Dashboard Qi App",
		"TotalEvents":         14,
		"TotalOffers":         5,
		"ForcedStatus":        forcedStatus.Value,
		"ClosingTime":         closingTime.Value,
		"OpeningTime":         openingTime.Value,
		"ForcedKitchenStatus": forcedKitchenStatus.Value,
		"KitchenClosingTime":  kitchenClosingTime.Value,
		"KitchenOpeningTime":  kitchenOpeningTime.Value,
	}

	c.HTML(http.StatusOK, "dashboard.html", data)
}

func (h *DashboardHandler) UpdateSettings(c *gin.Context) {
	forcedStatus := c.PostForm("forced_status")
	closingTime := c.PostForm("closing_time")
	openingTime := c.PostForm("opening_time")
	forcedKitchenStatus := c.PostForm("forced_kitchen_status")
	kitchenClosingTime := c.PostForm("kitchen_closing_time")
	kitchenOpeningTime := c.PostForm("kitchen_opening_time")

	if forcedStatus != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "forced_status").Update("value", forcedStatus)
	}
	if closingTime != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "closing_time").Update("value", closingTime)
	}
	if openingTime != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "opening_time").Update("value", openingTime)
	}
	if forcedKitchenStatus != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "forced_kitchen_status").Update("value", forcedKitchenStatus)
	}
	if kitchenClosingTime != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "kitchen_closing_time").Update("value", kitchenClosingTime)
	}
	if kitchenOpeningTime != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "kitchen_opening_time").Update("value", kitchenOpeningTime)
	}

	log.Println("Impostazioni orari aggiornate", forcedStatus, forcedKitchenStatus)

	c.Redirect(http.StatusFound, "/admin")
}
