package handlers

import (
	"net/http"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
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
	var req models.LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Dati non validi", "error": err.Error()})
		return
	}

	token, user, err := h.authService.Login(req)
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
	var req models.RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Campi mancanti o invalidi", "error": err.Error()})
		return
	}

	token, user, err := h.authService.SignUp(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"token":   token,
		"user":    user,
		"message": "Registrazione completata",
	})
}

// SocialLogin gestisce l'accesso e la registrazione tramite Google o Apple
func (h *AuthHandler) SocialLogin(c *gin.Context) {
	var req models.SocialLoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Campi social mancanti o invalidi", "error": err.Error()})
		return
	}

	token, user, err := h.authService.SocialLogin(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"token":   token,
		"user":    user,
		"message": "Accesso social completato",
	})
}
func (h *AuthHandler) UpdateFCMToken(c *gin.Context) {
	var req struct {
		FCMToken string `json:"fcm_token" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Token mancante"})
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Non autorizzato"})
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Utente non trovato"})
		return
	}

	if user.FCMToken != req.FCMToken {
		user.FCMToken = req.FCMToken
		database.DB.Save(&user)
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Token aggiornato"})
}
