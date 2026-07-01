package admin

import (
	"fmt"
	"log"
	"net/http"
	"qi-backend/internal/models"
	"qi-backend/internal/services"

	"github.com/gin-gonic/gin"
)

type AdminAuthHandler struct {
	authService *services.AuthService
}

func NewAdminAuthHandler(service *services.AuthService) *AdminAuthHandler {
	return &AdminAuthHandler{authService: service}
}

func (h *AdminAuthHandler) RenderLogin(c *gin.Context) {
	c.HTML(http.StatusOK, "login.html", gin.H{})
}

func (h *AdminAuthHandler) Login(c *gin.Context) {
	email := c.PostForm("email")
	password := c.PostForm("password")

	req := models.LoginRequest{Email: email, Password: password}
	token, _, err := h.authService.Login(req)
	if err != nil {
		fmt.Printf("Errore login admin: %v\n", err)
		c.HTML(http.StatusUnauthorized, "login.html", gin.H{"Error": "Credenziali non valide o utente inesistente"})
		return
	}

	log.Printf("Admin Login success, setting cookie: admin_token...")
	// c.SetCookie("admin_token", token, 3600*24*365, "/", "localhost", false, true)
	c.SetCookie("admin_token", token, 3600*24*365, "/", "", false, true)
	c.Redirect(http.StatusSeeOther, "/admin/")
}

func (h *AdminAuthHandler) Logout(c *gin.Context) {
	c.SetCookie("admin_token", "", -1, "/", "", false, true)
	c.Redirect(http.StatusSeeOther, "/admin/login")
}
