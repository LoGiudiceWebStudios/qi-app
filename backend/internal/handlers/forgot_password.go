package handlers

import (
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"golang.org/x/crypto/bcrypt"

	"github.com/gin-gonic/gin"
	"gopkg.in/gomail.v2"
)

func ForgotPassword(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Request non valida", "invalid_request"))
		return
	}

	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		// Non sveliamo se l'utente esiste o no. Rispondiamo comunque ok.
		c.JSON(http.StatusOK, models.SuccessResponse("Se l'email esiste, riceverai un codice per reimpostare la password.", nil))
		return
	}

	// Genera codice 4 cifre
	rand.Seed(time.Now().UnixNano())
	code := fmt.Sprintf("%04d", rand.Intn(10000))

	expiresAt := time.Now().Add(15 * time.Minute)
	user.ResetCode = &code
	user.ResetCodeExpiresAt = &expiresAt
	if err := database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore server", "server_error"))
		return
	}

	// Invia email via gomail (background)
	go sendResetEmail(user.Email, code)

	c.JSON(http.StatusOK, models.SuccessResponse("Se l'email esiste, riceverai un codice per reimpostare la password.", nil))
}

func sendResetEmail(to, code string) {
	host := os.Getenv("SMTP_HOST")
	portStr := os.Getenv("SMTP_PORT")
	user := os.Getenv("SMTP_USER")
	pass := os.Getenv("SMTP_PASSWORD")

	if host == "" || pass == "" {
		fmt.Println("SMTP credenziali non configurate")
		return
	}

	port, _ := strconv.Atoi(portStr)

	m := gomail.NewMessage()
	m.SetHeader("From", user)
	m.SetHeader("To", to)
	m.SetHeader("Subject", "Codice Ripristino Password - Qi App")
	m.SetBody("text/plain", fmt.Sprintf("Il tuo codice per il ripristino della password è: %s\n\nAttenzione: il codice scade tra 15 minuti.", code))

	d := gomail.NewDialer(host, port, user, pass)
	if err := d.DialAndSend(m); err != nil {
		fmt.Println("Errore nell'invio dell'email: ", err)
	}
}

func VerifyResetCode(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
		Code  string `json:"code" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Request non valida", "invalid_request"))
		return
	}

	var user models.User
	if err := database.DB.Where("email = ? AND reset_code = ?", req.Email, req.Code).First(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice errato o scaduto", "invalid_code"))
		return
	}

	if user.ResetCodeExpiresAt == nil || time.Now().After(*user.ResetCodeExpiresAt) {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice errato o scaduto", "invalid_code"))
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse("Codice corretto", nil))
}

func ResetPassword(c *gin.Context) {
	var req struct {
		Email       string `json:"email" binding:"required,email"`
		Code        string `json:"code" binding:"required"`
		NewPassword string `json:"new_password" binding:"required,min=8"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Request non valida", "invalid_request"))
		return
	}

	var user models.User
	if err := database.DB.Where("email = ? AND reset_code = ?", req.Email, req.Code).First(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice errato o scaduto", "invalid_code"))
		return
	}

	if user.ResetCodeExpiresAt == nil || time.Now().After(*user.ResetCodeExpiresAt) {
		c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice errato o scaduto", "invalid_code"))
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore server", "server_error"))
		return
	}

	user.Password = string(hashedPassword)
	user.ResetCode = nil
	user.ResetCodeExpiresAt = nil
	if err := database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore salvataggio password", "db_error"))
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse("Password reimpostata con successo. Ora puoi accedere.", nil))
}
