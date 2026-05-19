package admin

import (
    "net/http"

    "github.com/gin-gonic/gin"
	"strconv"
    "qi-backend/internal/database"
    "qi-backend/internal/models"
    "qi-backend/internal/services"
)

type NotificationsHandler struct{}

func NewNotificationsHandler() *NotificationsHandler {
    return &NotificationsHandler{}
}

// Vista della pagina per inviare notifiche manuali
func (h *NotificationsHandler) Index(c *gin.Context) {
    c.HTML(http.StatusOK, "notifications_index.html", gin.H{
        "Title": "Gestione Notifiche",
    })
}

// Richiesta POST per inviare una notifica manuale dal form Admin
func (h *NotificationsHandler) SendPost(c *gin.Context) {
    titolo := c.PostForm("titolo")
    messaggio := c.PostForm("messaggio")

    if titolo == "" || messaggio == "" {
        c.String(http.StatusBadRequest, "Titolo e messaggio sono obbligatori")
        return
    }

    var users []models.User
    database.DB.Where("fcm_token != ''").Find(&users)

    var tokens []string
    for _, u := range users {
        tokens = append(tokens, u.FCMToken)
    }

    if len(tokens) > 0 {
        err := services.SendMulticastNotification(titolo, messaggio, tokens)
        if err != nil {
            c.String(http.StatusInternalServerError, "Errore durante l'invio delle notifiche: " + err.Error())
            return
        }
    }

    c.Redirect(http.StatusSeeOther, "/admin/notifications?success=1&count=" + strconv.Itoa(len(tokens)))
}
