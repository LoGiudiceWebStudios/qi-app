package admin

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
	"qi-backend/internal/services"

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

	// Fix path slashes per immagini vecchie rimaste nel database o salvate da Windows
	for i := range rewards {
		if len(rewards[i].ImmagineURL) > 0 {
			rewards[i].ImmagineURL = filepath.ToSlash(rewards[i].ImmagineURL)
			if !strings.HasPrefix(rewards[i].ImmagineURL, "http") {
				if rewards[i].ImmagineURL[0] != '/' {
					rewards[i].ImmagineURL = "/" + rewards[i].ImmagineURL
				}
			}
		}
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

	punti, _ := strconv.Atoi(puntiRichiestiStr)

	// Gestione salvataggio Immagine
	var immagineURL string
	file, err := c.FormFile("immagine")
	if err == nil {
		if mkErr := os.MkdirAll("uploads/rewards", os.ModePerm); mkErr != nil {
			log.Printf("Errore creazione cartella rewards: %v", mkErr)
			c.HTML(http.StatusOK, "reward_new.html", gin.H{
				"Title": "Nuovo Premio",
				"Error": "Impossibile preparare il salvataggio immagine",
			})
			return
		}

		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), filepath.Base(file.Filename))
		outPath := filepath.Join("uploads/rewards", filename)

		if finalPath, saveErr := services.CompressAndSaveImage(file, outPath); saveErr == nil {
			imageFinalUrl := filepath.ToSlash(finalPath)
			immagineURL = "/" + imageFinalUrl // Lo salviamo come stringa da servire
		} else {
			log.Printf("Errore upload immagine premio: %v", saveErr)
			c.HTML(http.StatusOK, "reward_new.html", gin.H{
				"Title": "Nuovo Premio",
				"Error": "Upload immagine non riuscito. Prova con un file JPG o PNG.",
			})
			return
		}
	} else if err != http.ErrMissingFile {
		log.Printf("Errore lettura file premio: %v", err)
		c.HTML(http.StatusOK, "reward_new.html", gin.H{
			"Title": "Nuovo Premio",
			"Error": "Errore durante la lettura del file immagine",
		})
		return
	}

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

	// Invia notifica agli user
	var users []models.User
	database.DB.Where("fcm_token != ''").Find(&users)
	var tokens []string
	for _, u := range users {
		tokens = append(tokens, u.FCMToken)
	}
	if len(tokens) > 0 {
		services.SendMulticastNotification("Nuovo Premio Caricato!", "È disponibile un nuovo premio: "+titolo, tokens)
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
