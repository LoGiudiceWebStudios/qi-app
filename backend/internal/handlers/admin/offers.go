package admin

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
	"qi-backend/internal/services"
)

type OffersHandler struct{}

func NewOffersHandler() *OffersHandler {
	return &OffersHandler{}
}

func (h *OffersHandler) List(c *gin.Context) {
	var offers []models.Offer
	if err := database.DB.Order("created_at desc").Find(&offers).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore nel caricamento delle offerte")
		return
	}
	c.HTML(http.StatusOK, "offers.html", gin.H{
		"Title":  "Gestione Offerte",
		"Offers": offers,
	})
}

func (h *OffersHandler) CreateGet(c *gin.Context) {
	c.HTML(http.StatusOK, "offer_new.html", gin.H{
		"Title": "Crea Nuova Offerta",
	})
}

func (h *OffersHandler) CreatePost(c *gin.Context) {
	titolo := c.PostForm("titolo")
	descrizione := c.PostForm("descrizione")
	validaDalStr := c.PostForm("valida_dal")
	validaFinoStr := c.PostForm("valida_fino")
	codiceSconto := c.PostForm("codice_sconto")

	layout := "2006-01-02"
	loc, _ := time.LoadLocation("Local")

	validaDal, err := time.ParseInLocation(layout, validaDalStr, loc)
	if err != nil {
		c.String(http.StatusBadRequest, "Data inizio non valida: %v", err)
		return
	}

	validaFino, err := time.ParseInLocation(layout, validaFinoStr, loc)
	if err != nil {
		c.String(http.StatusBadRequest, "Data fine non valida: %v", err)
		return
	}

	// Impostiamo l'ora alla fine della giornata per validaFino
	validaFino = validaFino.Add(23*time.Hour + 59*time.Minute + 59*time.Second)

	// Gestione Immagine
	file, _ := c.FormFile("immagine")
	var imagePath string
	if file != nil {
		ext := filepath.Ext(file.Filename)
		filename := fmt.Sprintf("%d%s", time.Now().Unix(), ext)
		uploadDir := "uploads/offers"

		if err := os.MkdirAll(uploadDir, 0755); err != nil {
			c.String(http.StatusInternalServerError, "Errore creazione cartella uploads")
			return
		}

		dst := filepath.Join(uploadDir, filename)
		if err := c.SaveUploadedFile(file, dst); err != nil {
			c.String(http.StatusInternalServerError, "Errore salvataggio immagine")
			return
		}
		// Rimuovi spazi e slash extra per il database
		imagePath = filepath.ToSlash(dst)
	}

	offer := models.Offer{
		Titolo:       titolo,
		Descrizione:  descrizione,
		ImmagineURL:  imagePath,
		ValidaDal:    validaDal,
		ValidaFino:   validaFino,
		CodiceSconto: codiceSconto,
	}

	if err := database.DB.Create(&offer).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore nel salvataggio")
		return
	}

	// Invia notifica agli user
	var users []models.User
	database.DB.Where("fcm_token != ''").Find(&users)
	var tokens []string
	for _, u := range users {
		tokens = append(tokens, u.FCMToken)
	}
	services.SendMulticastNotification("Nuova Offerta: "+titolo, "Approfitta della nuova offerta: "+descrizione, tokens)
	c.Redirect(http.StatusSeeOther, "/admin/offers")
}

func (h *OffersHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Delete(&models.Offer{}, id).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore eliminazione")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/offers")
}
