package admin

import (
	"log"
	"net/http"
	"strconv"

	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type RewardsHandler struct{}

func NewRewardsHandler() *RewardsHandler {
	return &RewardsHandler{}
}

func (h *RewardsHandler) List(c *gin.Context) {
	var rewards []models.Reward
	if err := database.DB.Order("created_at desc").Find(&rewards).Error; err != nil {
		log.Printf("Errore recupero premi: %v", err)
	}

	c.HTML(http.StatusOK, "rewards.html", gin.H{
		"Title":   "Gestione Premi",
		"Rewards": rewards,
	})
}

func (h *RewardsHandler) CreateGet(c *gin.Context) {
	c.HTML(http.StatusOK, "reward_new.html", gin.H{
		"Title": "Nuovo Premio",
	})
}

func (h *RewardsHandler) CreatePost(c *gin.Context) {
	titolo := c.PostForm("titolo")
	descrizione := c.PostForm("descrizione")
	puntiRichiestiStr := c.PostForm("punti_richiesti")
	immagineURL := c.PostForm("immagine_url")

	punti, _ := strconv.Atoi(puntiRichiestiStr)

	reward := models.Reward{
		Titolo:         titolo,
		Descrizione:    descrizione,
		PuntiRichiesti: punti,
		ImmagineURL:    immagineURL, // Può essere implementato l'upload immagine
	}

	if err := database.DB.Create(&reward).Error; err != nil {
		c.HTML(http.StatusOK, "reward_new.html", gin.H{
			"Title": "Nuovo Premio",
			"Error": "Errore durante la creazione del premio",
		})
		return
	}

	c.Redirect(http.StatusSeeOther, "/admin/rewards")
}

func (h *RewardsHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Where("id = ?", id).Delete(&models.Reward{}).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore eliminazione")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/rewards")
}
