package handlers

import (
	"fmt"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

func GetOffers(c *gin.Context) {
	var offers []models.Offer
	now := time.Now()
	startOfDay := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())

	if err := database.DB.Where("valida_dal <= ? AND valida_fino >= ?", now, startOfDay).Order("valida_fino ASC").Find(&offers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Impossibile recuperare le offerte", "errore_database"))
		return
	}

	payload := make([]models.OfferAPI, 0, len(offers))
	for _, offer := range offers {
		imgURL := normalizeOfferImageURL(c, offer.ImmagineURL)
		actionText := "Get Code"
		if strings.TrimSpace(offer.CodiceSconto) == "" {
			actionText = "Get Code"
		}
		terms := fmt.Sprintf("Offerta valida dal %s al %s. Verifica disponibilita in cassa prima dell'uso.", offer.ValidaDal.Format("02/01/2006"), offer.ValidaFino.Format("02/01/2006"))
		payload = append(payload, models.OfferAPI{ID: fmt.Sprintf("%d", offer.ID), ImageURL: imgURL, Title: offer.Titolo, Description: offer.Descrizione, TermsText: &terms, ActionText: actionText, Code: offer.CodiceSconto})
	}

	c.JSON(http.StatusOK, models.SuccessResponse("Offerte recuperate con successo", payload))
}

func normalizeOfferImageURL(c *gin.Context, raw string) string {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return ""
	}
	normalized := filepath.ToSlash(trimmed)
	normalized = strings.TrimPrefix(normalized, "/")
	if strings.HasPrefix(normalized, "http://") || strings.HasPrefix(normalized, "https://") {
		return normalized
	}
	scheme := "http"
	if c.Request.TLS != nil {
		scheme = "https"
	}
	return fmt.Sprintf("%s://%s/%s", scheme, c.Request.Host, normalized)
}

func GenerateOfferCode(c *gin.Context) {
	offerID := c.Param("id")
	userID, exists := c.Get("user_id")

	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse("Non autorizzato", "unauthorized"))
		return
	}

	var offer models.Offer
	if err := database.DB.First(&offer, offerID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse("Offerta non trovata", "not_found"))
		return
	}

	// Calculate expiration (+20 minutes)
	expiresAt := time.Now().Add(20 * time.Minute)

	// Calcola l'ID in formato corretto sapendo che da JSON/JWT potrebbe arrivare come float64
	var uid uint
	switch v := userID.(type) {
	case float64:
		uid = uint(v)
	case uint:
		uid = v
	default:
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore conversione ID", "id_error"))
		return
	}

	// Create a simple random code like QI-OFF-XXYYZZ
	code := fmt.Sprintf("QI-OFF-%d-%d-%d", offer.ID, time.Now().Unix()%100000, uid)

	offerCode := models.OfferCode{
		OfferID:   offer.ID,
		UserID:    uid,
		Code:      code,
		ExpiresAt: expiresAt,
		IsUsed:    false,
	}

	if err := database.DB.Create(&offerCode).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore nella generazione del codice", "db_error"))
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse("Codice generato con successo", gin.H{
		"code":       offerCode.Code,
		"expires_at": offerCode.ExpiresAt.Format(time.RFC3339),
	}))
}

func ValidateOfferCode(c *gin.Context) {
	var req struct {
		Code string `json:"code" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Dati non validi", "invalid_data"))
		return
	}

	var offerCode models.OfferCode
	if err := database.DB.Where("code = ?", req.Code).Preload("Offer").First(&offerCode).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse("Codice non trovato", "not_found"))
		return
	}

	if offerCode.IsUsed {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice già utilizzato", "already_used"))
		return
	}

	if time.Now().After(offerCode.ExpiresAt) {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice scaduto", "expired"))
		return
	}

	// Significa che è valido, procediamo a invalidarlo
	now := time.Now()
	offerCode.IsUsed = true
	offerCode.UsedAt = &now

	if err := database.DB.Save(&offerCode).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore durante la convalida", "db_error"))
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse("Offerta convalidata con successo", gin.H{
		"offer_title": offerCode.Offer.Titolo,
		"used_at":     offerCode.UsedAt,
	}))
}
