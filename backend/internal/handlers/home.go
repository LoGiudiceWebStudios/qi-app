package handlers

import (
	"net/http"
	"qi-backend/internal/models"
	"qi-backend/internal/services"

	"github.com/gin-gonic/gin"
)

type HomeHandler struct {
	homeService *services.HomeService
}

// Iniezione delle dipendenze per l'handler della home
func NewHomeHandler(service *services.HomeService) *HomeHandler {
	return &HomeHandler{
		homeService: service,
	}
}

// GetHomeData restituisce tutti i dati necessari per popolare la home (orari, eventi, offerte)
func (h *HomeHandler) GetHomeData(c *gin.Context) {
	// Qui la logica delega subito al service layer
	data, err := h.homeService.GetHomeData()
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Impossibile recuperare i dati della home", err.Error()))
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse("Dati home caricati con successo", data))
}
