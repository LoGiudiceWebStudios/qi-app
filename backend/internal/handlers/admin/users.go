package admin

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UsersHandler struct{}

func NewUsersHandler() *UsersHandler {
	return &UsersHandler{}
}

func (h *UsersHandler) HandleIndex(c *gin.Context) {
	search := strings.TrimSpace(c.Query("q"))
	var users []models.User
	query := database.DB.Where("ruolo = ?", "user")
	if search != "" {
		like := "%" + search + "%"
		query = query.Where("nome ILIKE ? OR cognome ILIKE ? OR email ILIKE ? OR telefono ILIKE ?", like, like, like, like)
	}

	if err := query.Order("id desc").Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nel caricamento degli utenti"})
		return
	}

	c.HTML(http.StatusOK, "users.html", gin.H{
		"Title":       "Gestione Utenti",
		"Users":       users,
		"Search":      search,
		"Deleted":     c.Query("deleted") == "1",
		"PointsAdded": c.Query("points_added") == "1",
		"Error":       c.Query("error"),
	})
}

func (h *UsersHandler) AddPoints(c *gin.Context) {
	id := c.Param("id")
	points, err := strconv.Atoi(strings.TrimSpace(c.PostForm("points")))
	if err != nil || points <= 0 {
		c.Redirect(http.StatusSeeOther, "/admin/users?error=points")
		return
	}

	err = database.DB.Transaction(func(tx *gorm.DB) error {
		var user models.User
		if err := tx.Where("id = ? AND ruolo = ?", id, "user").First(&user).Error; err != nil {
			return err
		}

		user.Punti += points
		if err := tx.Save(&user).Error; err != nil {
			return err
		}

		return tx.Create(&models.PointsTransaction{
			UserID:      user.ID,
			Points:      points,
			Description: fmt.Sprintf("Accredito manuale dashboard admin (%d punti)", points),
			CreatedAt:   time.Now(),
		}).Error
	})
	if err != nil {
		c.Redirect(http.StatusSeeOther, "/admin/users?error=points")
		return
	}

	c.Redirect(http.StatusSeeOther, "/admin/users?points_added=1")
}

func (h *UsersHandler) RedirectToUsers(c *gin.Context) {
	c.Redirect(http.StatusSeeOther, "/admin/users")
}

func (h *UsersHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	result := database.DB.Where("id = ? AND ruolo = ?", id, "user").Delete(&models.User{})
	if result.Error != nil {
		c.Redirect(http.StatusSeeOther, "/admin/users?error=delete")
		return
	}
	if result.RowsAffected == 0 {
		c.Redirect(http.StatusSeeOther, "/admin/users?error=not-found")
		return
	}

	c.Redirect(http.StatusSeeOther, "/admin/users?deleted=1")
}
