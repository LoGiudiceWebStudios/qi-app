package handlers

import (
	"net/http"

	"qi-backend/internal/services"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	authService *services.AuthService
}

func NewAuthHandler(service *services.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: service,
	}
}

// Login elabora la richiesta di autenticazione dall'app
func (h *AuthHandler) Login(c *gin.Context) {
	var req struct {
		Email    string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Dati non validi", "error": err.Error()})
		return
	}

	// L'esito simulato al momento, oppure la vera chiamata al servizio
	token, user, err := h.authService.Login(req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"token":   token,
		"user":    user,
		"message": "Accesso consentito",
	})
}

// SignUp registra un nuovo utente
func (h *AuthHandler) SignUp(c *gin.Context) {
	var req struct {
		Nome     string `json:"nome" binding:"required"`
		Cognome  string `json:"cognome" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Campi mancanti o invalidi", "error": err.Error()})
		return
	}

	user, err := h.authService.SignUp(req.Nome, req.Cognome, req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"user":    user,
		"message": "Registrazione completata",
	})
}
