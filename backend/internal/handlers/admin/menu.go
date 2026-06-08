package admin

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"qi-backend/internal/database"
	"strconv"
	"time"

	"qi-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type MenuHandler struct{}

func NewMenuHandler() *MenuHandler {
	return &MenuHandler{}
}

// -------------------------------------------------------------
// FRONTEND API (JSON)
// -------------------------------------------------------------

func (h *MenuHandler) ListCategoriesAPI(c *gin.Context) {
	var categories []models.Category
	if err := database.DB.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossibile recuperare le categorie"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": categories})
}

func (h *MenuHandler) GetCategoryProductsAPI(c *gin.Context) {
	catID := c.Param("id")
	var products []models.Product
	if err := database.DB.Where("category_id = ?", catID).Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossibile recuperare i prodotti"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": products})
}

// -------------------------------------------------------------
// BACKOFFICE HTMX / HTML
// -------------------------------------------------------------

func (h *MenuHandler) RenderMenu(c *gin.Context) {
	var categories []models.Category
	// Preload the related products for the view
	database.DB.Preload("Products").Find(&categories)

	c.HTML(http.StatusOK, "menu.html", gin.H{
		"Title":      "Gestione Menu",
		"Categories": categories,
	})
}

func (h *MenuHandler) CreateCategory(c *gin.Context) {
	name := c.PostForm("name")
	desc := c.PostForm("description")

	if name == "" {
		c.String(http.StatusBadRequest, "Il nome della categoria è obbligatorio")
		return
	}

	var imageURL string
	file, err := c.FormFile("immagine")
	if err == nil {
		os.MkdirAll("uploads/categories", os.ModePerm)
		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), file.Filename)
		filepath := fmt.Sprintf("uploads/categories/%s", filename)
		if err := c.SaveUploadedFile(file, filepath); err == nil {
			imageURL = "/" + filepath
		}
	}

	category := models.Category{
		Name:        name,
		Description: desc,
		ImageURL:    imageURL,
	}

	if err := database.DB.Create(&category).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore nella creazione della categoria")
		return
	}

	// Redirect to menu page to refresh the view
	c.Redirect(http.StatusSeeOther, "/admin/menu")
}

func (h *MenuHandler) CreateProduct(c *gin.Context) {
	c.Request.ParseForm()

	catIDStr := c.PostForm("category_id")
	name := c.PostForm("name")
	shortDesc := c.PostForm("short_desc")
	desc := c.PostForm("description")
	priceStr := c.PostForm("price")

	catID, _ := strconv.ParseUint(catIDStr, 10, 32)
	price, _ := strconv.ParseFloat(priceStr, 64)

	var imageURL string
	var modelURL string
	file3d, err3d := c.FormFile("modello_3d")
	if err3d == nil {
		os.MkdirAll("uploads/models3d", os.ModePerm)
		filename3d := fmt.Sprintf("%d_%s", time.Now().Unix(), file3d.Filename)
		filepath3d := fmt.Sprintf("uploads/models3d/%s", filename3d)
		if err := c.SaveUploadedFile(file3d, filepath3d); err == nil {
			modelURL = "/" + filepath3d
		}
	}
	file, err := c.FormFile("immagine")
	if err == nil {
		os.MkdirAll("uploads/products", os.ModePerm)
		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), file.Filename)
		filepath := fmt.Sprintf("uploads/products/%s", filename)
		if err := c.SaveUploadedFile(file, filepath); err == nil {
			imageURL = "/" + filepath
		}
	}

	product := models.Product{
		CategoryID:  uint(catID),
		Name:        name,
		ShortDesc:   shortDesc,
		Description: desc,
		Price:       price,
		ImageURL:    imageURL,
		Model3dUrl:  modelURL,
	}

	if err := database.DB.Create(&product).Error; err != nil {
		log.Println("Errore salvataggio prodotto:", err)
	}

	c.Redirect(http.StatusSeeOther, "/admin/menu")
}

func (h *MenuHandler) DeleteCategory(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Delete(&models.Category{}, id).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore l'eliminazione")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/menu")
}

func (h *MenuHandler) DeleteProduct(c *gin.Context) {
	id := c.Param("id")
	if err := database.DB.Delete(&models.Product{}, id).Error; err != nil {
		c.String(http.StatusInternalServerError, "Errore l'eliminazione")
		return
	}
	c.Redirect(http.StatusSeeOther, "/admin/menu")
}
