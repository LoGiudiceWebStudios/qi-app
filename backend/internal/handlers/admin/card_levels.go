package admin

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
	"qi-backend/internal/services"
)

type CardLevelsHandler struct{}

func NewCardLevelsHandler() *CardLevelsHandler {
	return &CardLevelsHandler{}
}
func (h *CardLevelsHandler) List(c *gin.Context) {
	var levels []models.CardLevel
	if err := database.DB.Order("name asc").Find(&levels).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore caricamento livelli cliente")
		return
	}
	c.HTML(http.StatusOK, "card_levels.html", gin.H{
		"Title":  "Livelli Cliente",
		"Levels": levels,
		"Error":  c.Query("error"),
	})
}

func (h *CardLevelsHandler) Create(c *gin.Context) {
	level, err := cardLevelFromForm(c)
	if err != nil {
		c.Redirect(http.StatusSeeOther, "/admin/card-levels?error=invalid")
		return
	}
	imageURL, err := saveCardLevelImage(c)
	if err != nil {
		c.Redirect(http.StatusSeeOther, "/admin/card-levels?error=image")
		return
	}
	level.BackgroundImageURL = imageURL
	if err := database.DB.Create(&level).Error; err != nil {
		c.Redirect(http.StatusSeeOther, "/admin/card-levels?error=duplicate")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/card-levels")
}

func (h *CardLevelsHandler) Edit(c *gin.Context) {
	var level models.CardLevel
	if err := database.DB.First(&level, c.Param("id")).Error; err != nil {
		c.String(http.StatusNotFound, "Livello cliente non trovato")
		return
	}
	c.HTML(http.StatusOK, "card_level_edit.html", gin.H{
		"Title": "Modifica livello cliente",
		"Level": level,
	})
}

func (h *CardLevelsHandler) Update(c *gin.Context) {
	var level models.CardLevel
	if err := database.DB.First(&level, c.Param("id")).Error; err != nil {
		c.String(http.StatusNotFound, "Livello cliente non trovato")
		return
	}
	updated, err := cardLevelFromForm(c)
	if err != nil {
		c.HTML(http.StatusBadRequest, "card_level_edit.html", gin.H{
			"Title": "Modifica livello cliente",
			"Level": level,
			"Error": "Controlla nome e colori inseriti.",
		})
		return
	}
	imageURL, err := saveCardLevelImage(c)
	if err != nil {
		c.HTML(http.StatusBadRequest, "card_level_edit.html", gin.H{
			"Title": "Modifica livello cliente",
			"Level": level,
			"Error": "Caricamento immagine non riuscito.",
		})
		return
	}
	level.Name = updated.Name
	level.Description = updated.Description
	level.DiscountLabel = updated.DiscountLabel
	level.PrimaryColor = updated.PrimaryColor
	level.SecondaryColor = updated.SecondaryColor
	if imageURL != "" {
		level.BackgroundImageURL = imageURL
	}
	if err := database.DB.Save(&level).Error; err != nil {
		c.HTML(http.StatusBadRequest, "card_level_edit.html", gin.H{
			"Title": "Modifica livello cliente",
			"Level": level,
			"Error": "Salvataggio non riuscito. Il nome potrebbe essere già utilizzato.",
		})
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/card-levels")
}

func (h *CardLevelsHandler) Delete(c *gin.Context) {
	err := database.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&models.User{}).Where("card_level_id = ?", c.Param("id")).Update("card_level_id", nil).Error; err != nil {
			return err
		}
		return tx.Delete(&models.CardLevel{}, c.Param("id")).Error
	})
	if err != nil {
		c.Redirect(http.StatusSeeOther, "/admin/card-levels?error=delete")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/card-levels")
}

func cardLevelFromForm(c *gin.Context) (models.CardLevel, error) {
	level := models.CardLevel{
		Name:           strings.TrimSpace(c.PostForm("name")),
		Description:    strings.TrimSpace(c.PostForm("description")),
		DiscountLabel:  strings.TrimSpace(c.PostForm("discount_label")),
		PrimaryColor:   strings.ToUpper(strings.TrimSpace(c.PostForm("primary_color"))),
		SecondaryColor: strings.ToUpper(strings.TrimSpace(c.PostForm("secondary_color"))),
	}
	if level.Name == "" || !validHexColor(level.PrimaryColor) || !validHexColor(level.SecondaryColor) {
		return level, fmt.Errorf("nome e colori validi sono obbligatori")
	}
	return level, nil
}

func validHexColor(value string) bool {
	matched, _ := regexp.MatchString(`^#[0-9A-F]{6}$`, value)
	return matched
}

func saveCardLevelImage(c *gin.Context) (string, error) {
	file, err := c.FormFile("background_image")
	if err == http.ErrMissingFile {
		return "", nil
	}
	if err != nil {
		return "", err
	}
	if err := os.MkdirAll("uploads/card_levels", os.ModePerm); err != nil {
		return "", err
	}
	filename := fmt.Sprintf("%d_%s", time.Now().UnixNano(), filepath.Base(file.Filename))
	outPath := filepath.Join("uploads/card_levels", filename)
	finalPath, err := services.CompressAndSaveImage(file, outPath)
	if err != nil {
		return "", err
	}
	return "/" + filepath.ToSlash(finalPath), nil
}
