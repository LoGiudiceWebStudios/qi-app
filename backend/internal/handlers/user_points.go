package handlers

import (
        "net/http"
        "time"
        "fmt"

        "gorm.io/gorm"
        "github.com/gin-gonic/gin"

        "qi-backend/internal/database"
        "qi-backend/internal/models"
)

type UserPointsHandler struct{}

func NewUserPointsHandler() *UserPointsHandler {
        return &UserPointsHandler{}
}

// ClaimPoints validate a QR code and gives point to user
func (h *UserPointsHandler) ClaimPoints(c *gin.Context) {
        userID, exists := c.Get("user_id")
        if !exists {
                c.JSON(http.StatusUnauthorized, models.ErrorResponse("Non autorizzato", "unauthorized"))
                return
        }

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

        var req struct {
                Code string `json:"code" binding:"required"`
        }
        if err := c.ShouldBindJSON(&req); err != nil {
                c.JSON(http.StatusBadRequest, models.ErrorResponse("Dati non validi", "invalid_data"))
                return
        }

        // Check the QR Code Token
        var qr models.PointsQRCode
        if err := database.DB.Where("code = ?", req.Code).First(&qr).Error; err != nil {
                c.JSON(http.StatusNotFound, models.ErrorResponse("Codice QR non trovato", "not_found"))
                return
        }

        if qr.IsUsed {
                c.JSON(http.StatusBadRequest, models.ErrorResponse("Questo codice e' gia stato utilizzato", "already_used"))
                return
        }

        if time.Now().After(qr.ExpiresAt) {
                c.JSON(http.StatusBadRequest, models.ErrorResponse("Codice scaduto", "expired"))
                return
        }

        // Get User
        var user models.User
        if err := database.DB.First(&user, uid).Error; err != nil {
                c.JSON(http.StatusNotFound, models.ErrorResponse("Utente non trovato", "user_not_found"))
                return
        }

        // Perform Transaction
        err := database.DB.Transaction(func(tx *gorm.DB) error {
                // Update User
                user.Punti += qr.PointsToAward
                if err := tx.Save(&user).Error; err != nil {
                        return err
                }

                // Invalidate QR
                qr.IsUsed = true
                qr.UsedByUserID = &uid
                if err := tx.Save(&qr).Error; err != nil {
                        return err
                }

                // Log Transaction
                transaction := models.PointsTransaction{
                        UserID:      uid,
                        Points:      qr.PointsToAward,
                        Description: fmt.Sprintf("Raccolta punti tramite QR in cassa (%d punti)", qr.PointsToAward),
                }
                if err := tx.Create(&transaction).Error; err != nil {
                        return err
                }

                return nil
        })

        if err != nil {
                c.JSON(http.StatusInternalServerError, models.ErrorResponse("Errore durante l'accredito dei punti", "db_error"))
                return
        }

        c.JSON(http.StatusOK, models.SuccessResponse("Punti accreditati con successo", gin.H{
                "points_awarded": qr.PointsToAward,
                "total_points":   user.Punti,
        }))
}

