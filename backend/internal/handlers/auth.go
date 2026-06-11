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

// RequestSignUp avvia il processo inviando il codice
func (h *AuthHandler) RequestSignUp(c *gin.Context) {
	var req models.RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Campi mancanti o invalidi", "error": err.Error()})
		return
	}

	err := h.authService.RequestSignUp(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Codice di verifica inviato all'email",
	})
}

// VerifySignUp controlla il codice e crea l'utente definitivo
func (h *AuthHandler) VerifySignUp(c *gin.Context) {
	var req struct {
		Email    string `json:"email" binding:"required,email"`
		Code     string `json:"code" binding:"required"`
		FCMToken string `json:"fcm_token,omitempty"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Dati non validi", "error": err.Error()})
		return
	}

	token, user, err := h.authService.VerifySignUp(req.Email, req.Code, req.FCMToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"token":   token,
		"user":    user,
		"message": "Registrazione completata con successo",
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

func (h *AuthHandler) GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var uid uint
	switch v := userID.(type) {
	case float64:
		uid = uint(v)
	case uint:
		uid = v
	}
	user, err := h.authService.GetProfile(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore caricamento profilo"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var req struct {
		Nome     string `json:"nome"`
		Cognome  string `json:"cognome"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var uid uint
	switch v := userID.(type) {
	case float64:
		uid = uint(v)
	case uint:
		uid = v
	}
	if err := h.authService.UpdateProfile(uid, req.Nome, req.Cognome, req.Email, req.Password); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore aggiornamento profilo"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Profilo aggiornato con successo"})
}
