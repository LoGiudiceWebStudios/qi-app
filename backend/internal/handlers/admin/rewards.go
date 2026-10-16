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

func (h *RewardsHandler) EditGet(c *gin.Context) {
	var reward models.Reward
	if err := database.DB.First(&reward, c.Param("id")).Error; err != nil {
		c.String(http.StatusNotFound, "Premio non trovato")
		return
	}
	c.HTML(http.StatusOK, "reward_edit.html", gin.H{
		"Title":  "Modifica Premio",
		"Reward": reward,
	})
}

func (h *RewardsHandler) CreatePost(c *gin.Context) {
	titolo := c.PostForm("titolo")
	descrizione := c.PostForm("descrizione")
	puntiRichiestiStr := c.PostForm("punti_richiesti")

	punti, _ := strconv.Atoi(puntiRichiestiStr)
	sendNotification := c.PostForm("send_notification") != ""

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

	model3dURL, err := saveRewardModel(c, "modello_3d", "uploads/models3d", "", ".glb", ".gltf")
	if err != nil {
		c.HTML(http.StatusOK, "reward_new.html", gin.H{
			"Title": "Nuovo Premio",
			"Error": err.Error(),
		})
		return
	}
	reward := models.Reward{
		Titolo:         titolo,
		Descrizione:    descrizione,
		PuntiRichiesti: punti,
		ImmagineURL:    immagineURL, // Può essere implementato l'upload immagine
		Model3dURL:     model3dURL,
	}

	if err := database.DB.Create(&reward).Error; err != nil {
		c.HTML(http.StatusOK, "reward_new.html", gin.H{
			"Title": "Nuovo Premio",
			"Error": "Errore durante la creazione del premio",
		})
		return
	}

	if sendNotification {
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
	}

	c.Redirect(http.StatusSeeOther, "/admin/rewards")
}

func saveRewardModel(c *gin.Context, fieldName, directory, prefix string, allowedExtensions ...string) (string, error) {
	file, err := c.FormFile(fieldName)
	if err == http.ErrMissingFile {
		return "", nil
	}
	if err != nil {
		return "", fmt.Errorf("errore durante la lettura del modello 3D")
	}

	extension := strings.ToLower(filepath.Ext(file.Filename))
	allowed := false
	for _, candidate := range allowedExtensions {
		if extension == candidate {
			allowed = true
			break
		}
	}
	if !allowed {
		return "", fmt.Errorf("formato non valido per il file %s", fieldName)
	}
	if err := os.MkdirAll(directory, os.ModePerm); err != nil {
		return "", fmt.Errorf("impossibile preparare il salvataggio del modello 3D")
	}

	filename := fmt.Sprintf("%d_%s%s", time.Now().UnixNano(), prefix, filepath.Base(file.Filename))
	path := filepath.Join(directory, filename)
	if err := c.SaveUploadedFile(file, path); err != nil {
		return "", fmt.Errorf("upload del modello 3D non riuscito")
	}
	return "/" + filepath.ToSlash(path), nil
}

func (h *RewardsHandler) UpdatePost(c *gin.Context) {
	var reward models.Reward
	if err := database.DB.First(&reward, c.Param("id")).Error; err != nil {
		c.String(http.StatusNotFound, "Premio non trovato")
		return
	}

	reward.Titolo = c.PostForm("titolo")
	reward.Descrizione = c.PostForm("descrizione")
	punti, err := strconv.Atoi(c.PostForm("punti_richiesti"))
	if err != nil || punti < 1 {
		renderRewardEditError(c, reward, "Inserisci un numero di punti valido.")
		return
	}
	reward.PuntiRichiesti = punti

	image, imageErr := c.FormFile("immagine")
	if imageErr == nil {
		if err := os.MkdirAll("uploads/rewards", os.ModePerm); err != nil {
			renderRewardEditError(c, reward, "Impossibile preparare il salvataggio dell'immagine.")
			return
		}
		filename := fmt.Sprintf("%d_%s", time.Now().UnixNano(), filepath.Base(image.Filename))
		outPath := filepath.Join("uploads/rewards", filename)
		finalPath, err := services.CompressAndSaveImage(image, outPath)
		if err != nil {
			renderRewardEditError(c, reward, "Upload immagine non riuscito. Prova con un file JPG o PNG.")
			return
		}
		reward.ImmagineURL = "/" + filepath.ToSlash(finalPath)
	} else if imageErr != http.ErrMissingFile {
		renderRewardEditError(c, reward, "Errore durante la lettura del file immagine.")
		return
	}

	model3dURL, err := saveRewardModel(c, "modello_3d", "uploads/models3d", "", ".glb", ".gltf")
	if err != nil {
		renderRewardEditError(c, reward, err.Error())
		return
	}
	if model3dURL != "" {
		reward.Model3dURL = model3dURL
	}
	if err := database.DB.Save(&reward).Error; err != nil {
		renderRewardEditError(c, reward, "Errore durante il salvataggio del premio.")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/rewards")
}

func renderRewardEditError(c *gin.Context, reward models.Reward, message string) {
	c.HTML(http.StatusOK, "reward_edit.html", gin.H{
		"Title":  "Modifica Premio",
		"Reward": reward,
		"Error":  message,
	})
}

func (h *RewardsHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Where("id = ?", id).Delete(&models.Reward{}).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore eliminazione")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/rewards")
}
