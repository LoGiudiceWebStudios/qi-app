package admin

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
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

	for i := range offers {
		if len(offers[i].ImmagineURL) > 0 {
			offers[i].ImmagineURL = filepath.ToSlash(offers[i].ImmagineURL)
			if !strings.HasPrefix(offers[i].ImmagineURL, "http") {
				if offers[i].ImmagineURL[0] != '/' {
					offers[i].ImmagineURL = "/" + offers[i].ImmagineURL
				}
			}
		}
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
		if finalPath, err := services.CompressAndSaveImage(file, dst); err != nil {
			c.String(http.StatusInternalServerError, "Errore salvataggio immagine compressa")
			return
		} else {
			// Rimuovi spazi e slash extra per il database
			imagePath = "/" + filepath.ToSlash(finalPath)
		}
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

func (h *OffersHandler) EditGet(c *gin.Context) {
	id := c.Param("id")
	var offer models.Offer
	if err := database.DB.First(&offer, id).Error; err != nil {
		c.String(http.StatusNotFound, "Offerta non trovata")
		return
	}

	c.HTML(http.StatusOK, "offer_edit.html", gin.H{
		"Title": "Modifica Offerta",
		"Offer": offer,
	})
}

func (h *OffersHandler) UpdatePost(c *gin.Context) {
	id := c.Param("id")
	var offer models.Offer
	if err := database.DB.First(&offer, id).Error; err != nil {
		c.String(http.StatusNotFound, "Offerta non trovata")
		return
	}

	offer.Titolo = c.PostForm("titolo")
	offer.Descrizione = c.PostForm("descrizione")
	offer.CodiceSconto = c.PostForm("codice_sconto")

	layout := "2006-01-02"
	loc, _ := time.LoadLocation("Local")

	if validaDalStr := c.PostForm("valida_dal"); validaDalStr != "" {
		if validaDal, err := time.ParseInLocation(layout, validaDalStr, loc); err == nil {
			offer.ValidaDal = validaDal
		}
	}

	if validaFinoStr := c.PostForm("valida_fino"); validaFinoStr != "" {
		if validaFino, err := time.ParseInLocation(layout, validaFinoStr, loc); err == nil {
			offer.ValidaFino = validaFino.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
		}
	}

	file, _ := c.FormFile("immagine")
	if file != nil {
		ext := filepath.Ext(file.Filename)
		filename := fmt.Sprintf("%d%s", time.Now().Unix(), ext)
		uploadDir := "uploads/offers"
		os.MkdirAll(uploadDir, 0755)

		dst := filepath.Join(uploadDir, filename)
		if finalPath, err := services.CompressAndSaveImage(file, dst); err == nil {
			offer.ImmagineURL = "/" + filepath.ToSlash(finalPath)
		}
	}

	if err := database.DB.Save(&offer).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore salvataggio offerta")
		return
	}

	c.Redirect(http.StatusSeeOther, "/admin/offers")
}
