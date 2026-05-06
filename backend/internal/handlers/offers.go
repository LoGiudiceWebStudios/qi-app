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

// GetOffers restituisce le offerte attive nel formato richiesto dal frontend.
func GetOffers(c *gin.Context) {
	var offers []models.Offer
	now := time.Now()

	if err := database.DB.
		Where("valida_dal <= ? AND valida_fino >= ?", now, now).
		Order("valida_fino ASC").
		Find(&offers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Impossibile recuperare le offerte", "errore_database"))
		return
	}

	if len(offers) == 0 {
		if err := database.DB.
			Order("created_at DESC").
			Limit(20).
			Find(&offers).Error; err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse("Impossibile recuperare le offerte", "errore_database"))
			return
		}
	}

	payload := make([]models.OfferAPI, 0, len(offers))
	for _, offer := range offers {
		imgURL := normalizeOfferImageURL(c, offer.ImmagineURL)
		actionText := "Get Code"
		if strings.TrimSpace(offer.CodiceSconto) == "" {
			actionText = "Scopri di piu"
		}

		terms := fmt.Sprintf(
			"Offerta valida dal %s al %s. Verifica disponibilita in cassa prima dell'uso.",
			offer.ValidaDal.Format("02/01/2006"),
			offer.ValidaFino.Format("02/01/2006"),
		)

		payload = append(payload, models.OfferAPI{
			ID:          fmt.Sprintf("%d", offer.ID),
			ImageURL:    imgURL,
			Title:       offer.Titolo,
			Description: offer.Descrizione,
			TermsText:   &terms,
			ActionText:  actionText,
			Code:        offer.CodiceSconto,
		})
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
