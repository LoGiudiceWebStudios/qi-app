package admin

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
	"qi-backend/internal/services"
)

type NotificationsHandler struct{}

func NewNotificationsHandler() *NotificationsHandler {
	return &NotificationsHandler{}
}

func (h *NotificationsHandler) Index(c *gin.Context) {
	var schedules []models.ScheduledNotification
	database.DB.Find(&schedules)

	c.HTML(http.StatusOK, "notifications_index.html", gin.H{
		"Title":     "Gestione Notifiche",
		"Schedules": schedules,
	})
}

func (h *NotificationsHandler) SendPost(c *gin.Context) {
	titolo := c.PostForm("titolo")
	messaggio := c.PostForm("messaggio")

	if titolo == "" || messaggio == "" {
		c.String(http.StatusBadRequest, "Titolo e messaggio sono obbligatori")
		return
	}

	var users []models.User
	database.DB.Where("fcm_token IS NOT NULL AND fcm_token != ?", "").Find(&users)

	var tokens []string
	for _, u := range users {
		tokens = append(tokens, u.FCMToken)
	}

	if len(tokens) > 0 {
		err := services.SendMulticastNotification(titolo, messaggio, tokens)
		if err != nil {
			c.String(http.StatusInternalServerError, "Errore durante l'invio delle notifiche: "+err.Error())
			return
		}
	}

	c.Redirect(http.StatusSeeOther, "/admin/notifications?success=1&count="+strconv.Itoa(len(tokens)))
}

func (h *NotificationsHandler) SchedulePost(c *gin.Context) {
	titolo := c.PostForm("schedule_titolo")
	messaggio := c.PostForm("schedule_messaggio")
	giornoStr := c.PostForm("giorno")
	ora := c.PostForm("ora")

	if titolo == "" || messaggio == "" || giornoStr == "" || ora == "" {
		c.String(http.StatusBadRequest, "Tutti i campi sono obbligatori")
		return
	}

	giorno, _ := strconv.Atoi(giornoStr)

	schedule := models.ScheduledNotification{
		Title:     titolo,
		Message:   messaggio,
		DayOfWeek: giorno,
		Time:      ora,
	}

	if err := database.DB.Create(&schedule).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore salvataggio")
		return
	}

	services.ReloadSchedules()

	c.Redirect(http.StatusSeeOther, "/admin/notifications?success=schedule")
}

func (h *NotificationsHandler) DeleteSchedule(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Delete(&models.ScheduledNotification{}, id).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore eliminazione")
		return
	}
	services.ReloadSchedules()
	c.Redirect(http.StatusSeeOther, "/admin/notifications")
}
