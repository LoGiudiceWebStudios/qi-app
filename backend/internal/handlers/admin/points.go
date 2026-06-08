package admin

import (
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

type PointsHandler struct{}

func NewPointsHandler() *PointsHandler {
	return &PointsHandler{}
}

// RenderPointsPage mostra la pagina UI html per i punti
func (h *PointsHandler) RenderPointsPage(c *gin.Context) {
	c.HTML(http.StatusOK, "points.html", gin.H{
		"Title": "Generazione Punti (Cassa) - Qi Admin",
	})
}

// GeneratePointsQRCode genera un token che l'utente puo scansionare per caricare punti
func (h *PointsHandler) GeneratePointsQRCode(c *gin.Context) {
	importoStr := c.PostForm("importo")
	moltiplicatoreStr := c.PostForm("moltiplicatore")

	importo, err := strconv.ParseFloat(importoStr, 64)
	if err != nil || importo <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Importo non valido"})
		return
	}

	moltiplicatore, err := strconv.ParseFloat(moltiplicatoreStr, 64)
	if err != nil || moltiplicatore <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Moltiplicatore non valido"})
		return
	}

	puntiDaAssegnare := int(importo * moltiplicatore)

	// Generazione codice unico
	rand.Seed(time.Now().UnixNano())
	codice := fmt.Sprintf("QI-PTS-%d-%d", time.Now().Unix(), rand.Intn(10000))

	qr := models.PointsQRCode{
		Code:          codice,
		PointsToAward: puntiDaAssegnare,
		IsUsed:        false,
		ExpiresAt:     time.Now().Add(10 * time.Minute),
	}

	if err := database.DB.Create(&qr).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore interno creando il QR."})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"code":    codice,
		"points":  puntiDaAssegnare,
	})
}

// DeductPoints decurta punti dal saldo utente (utilizzato dopo la scansione dalla cassa)
func (h *PointsHandler) DeductPoints(c *gin.Context) {
	var req struct {
		UserID uint `json:"user_id" binding:"required"`
		Points int  `json:"points" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Dati invalidi"})
		return
	}

	if req.Points <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "I punti da decurtare devono essere maggiori di 0"})
		return
	}

	var user models.User
	if err := database.DB.First(&user, req.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utente non trovato"})
		return
	}

	if user.Punti < req.Points {
		c.JSON(http.StatusBadRequest, gin.H{"error": "L'utente non ha abbastanza punti saldo."})
		return
	}

	user.Punti -= req.Points

	if err := database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Errore nel salvataggio."})
		return
	}

	tx := models.PointsTransaction{
		UserID:      user.ID,
		Points:      -req.Points,
		Description: "Decurtazione punti alla cassa",
		CreatedAt:   time.Now(),
	}
	database.DB.Create(&tx)

	c.JSON(http.StatusOK, gin.H{
		"success":     true,
		"message":     "Punti decurtati con successo",
		"nuovi_punti": user.Punti,
	})
}

// GetUserPoints restituisce i dati attuali (punti) per un determinato user_id
func (h *PointsHandler) GetUserPoints(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID utente non valido"})
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utente non trovato"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"id":      user.ID,
		"name":    user.Nome,
		"punti":   user.Punti,
	})
}
