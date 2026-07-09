package admin

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

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

	var venueSchedule models.Setting
	if err := database.DB.Where("key = ?", "venue_schedule").First(&venueSchedule).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "venue_schedule", Value: `{"monday":[],"tuesday":[],"wednesday":[],"thursday":[],"friday":[],"saturday":[],"sunday":[]}`})
	}

	var forcedKitchenStatus models.Setting
	if err := database.DB.Where("key = ?", "forced_kitchen_status").First(&forcedKitchenStatus).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "forced_kitchen_status", Value: "auto"})
	}

	var kitchenSchedule models.Setting
	if err := database.DB.Where("key = ?", "kitchen_schedule").First(&kitchenSchedule).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "kitchen_schedule", Value: `{"monday":[],"tuesday":[],"wednesday":[],"thursday":[],"friday":[],"saturday":[],"sunday":[]}`})
	}

	var authVersion models.Setting
	if err := database.DB.Where("key = ?", "auth_version").First(&authVersion).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "auth_version", Value: "1"})
		authVersion.Value = "1"
	}

	now := time.Now()
	startOfToday := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())

	var totalEvents int64
	if err := database.DB.Model(&models.Event{}).Where("data_evento >= ?", startOfToday).Count(&totalEvents).Error; err != nil {
		log.Printf("Errore conteggio eventi attivi: %v", err)
	}

	var totalOffers int64
	if err := database.DB.Model(&models.Offer{}).Where("valida_dal <= ? AND valida_fino >= ?", now, startOfToday).Count(&totalOffers).Error; err != nil {
		log.Printf("Errore conteggio offerte attive: %v", err)
	}

	data := gin.H{
		"Title":               "Dashboard Qi App",
		"TotalEvents":         totalEvents,
		"TotalOffers":         totalOffers,
		"ForcedStatus":        forcedStatus.Value,
		"VenueSchedule":       venueSchedule.Value,
		"ForcedKitchenStatus": forcedKitchenStatus.Value,
		"KitchenSchedule":     kitchenSchedule.Value,
		"AuthVersion":         authVersion.Value,
	}

	c.HTML(http.StatusOK, "dashboard.html", data)
}

func (h *DashboardHandler) UpdateSettings(c *gin.Context) {
	forcedStatus := c.PostForm("forced_status")
	venueSchedule := c.PostForm("venue_schedule")
	forcedKitchenStatus := c.PostForm("forced_kitchen_status")
	kitchenSchedule := c.PostForm("kitchen_schedule")

	if forcedStatus != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "forced_status").Update("value", forcedStatus)
	}
	if venueSchedule != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "venue_schedule").Update("value", venueSchedule)
	}
	if forcedKitchenStatus != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "forced_kitchen_status").Update("value", forcedKitchenStatus)
	}
	if kitchenSchedule != "" {
		database.DB.Model(&models.Setting{}).Where("key = ?", "kitchen_schedule").Update("value", kitchenSchedule)
	}

	log.Println("Impostazioni orari aggiornate", forcedStatus, forcedKitchenStatus)

	c.Redirect(http.StatusFound, "/admin")
}

func (h *DashboardHandler) ForceLogoutAll(c *gin.Context) {
	var authVersion models.Setting
	if err := database.DB.Where("key = ?", "auth_version").First(&authVersion).Error; err != nil {
		authVersion = models.Setting{Key: "auth_version", Value: "1"}
		database.DB.Create(&authVersion)
	}

	currentVersion, err := strconv.Atoi(authVersion.Value)
	if err != nil || currentVersion < 1 {
		currentVersion = 1
	}

	newVersion := currentVersion + 1
	database.DB.Model(&models.Setting{}).Where("key = ?", "auth_version").Update("value", fmt.Sprintf("%d", newVersion))

	log.Printf("Auth version incremented to %d: all sessions invalidated", newVersion)
	c.Redirect(http.StatusSeeOther, "/admin")
}
