package admin

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
	"qi-backend/internal/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
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
	if err := database.DB.Order("ordine asc, id asc").Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossibile recuperare le categorie"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": categories})
}

func (h *MenuHandler) GetCategoryProductsAPI(c *gin.Context) {
	catID := c.Param("id")
	var products []models.Product
	if err := database.DB.Where("category_id = ?", catID).Order("ordine asc, id asc").Find(&products).Error; err != nil {
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
	database.DB.Preload("Products", func(db *gorm.DB) *gorm.DB {
		return db.Order("ordine asc, id asc")
	}).Order("ordine asc, id asc").Find(&categories)

	c.HTML(http.StatusOK, "menu.html", gin.H{
		"Title":      "Gestione Menu",
		"Categories": categories,
	})
}

func (h *MenuHandler) CreateCategory(c *gin.Context) {
	name := c.PostForm("name")
	desc := c.PostForm("description")
	ordineStr := c.PostForm("ordine")
	ordine, _ := strconv.Atoi(ordineStr)

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
		if finalPath, err := services.CompressAndSaveImage(file, filepath); err == nil {
			imageURL = "/" + finalPath
		}
	}

	category := models.Category{
		Name:        name,
		Description: desc,
		ImageURL:    imageURL,
		Ordine:      ordine,
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
	ordineStr := c.PostForm("ordine")

	catID, _ := strconv.ParseUint(catIDStr, 10, 32)
	price, _ := strconv.ParseFloat(priceStr, 64)
	ordine, _ := strconv.Atoi(ordineStr)

	var imageURL string
	var modelURL string
	var modelIosURL string

	file3d, err3d := c.FormFile("modello_3d")
	if err3d == nil {
		os.MkdirAll("uploads/models3d", os.ModePerm)
		filename3d := fmt.Sprintf("%d_%s", time.Now().Unix(), file3d.Filename)
		filepath3d := fmt.Sprintf("uploads/models3d/%s", filename3d)
		if err := c.SaveUploadedFile(file3d, filepath3d); err == nil {
			modelURL = "/" + filepath3d
		}
	}

	file3dIos, err3dIos := c.FormFile("modello_3d_ios")
	if err3dIos == nil {
		os.MkdirAll("uploads/models3d", os.ModePerm)
		filename3dIos := fmt.Sprintf("%d_ios_%s", time.Now().Unix(), file3dIos.Filename)
		filepath3dIos := fmt.Sprintf("uploads/models3d/%s", filename3dIos)
		if err := c.SaveUploadedFile(file3dIos, filepath3dIos); err == nil {
			modelIosURL = "/" + filepath3dIos
		}
	}

	file, err := c.FormFile("immagine")
	if err == nil {
		os.MkdirAll("uploads/products", os.ModePerm)
		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), file.Filename)
		filepath := fmt.Sprintf("uploads/products/%s", filename)
		if finalPath, err := services.CompressAndSaveImage(file, filepath); err == nil {
			imageURL = "/" + finalPath
		}
	}

	product := models.Product{
		CategoryID:    uint(catID),
		Name:          name,
		ShortDesc:     shortDesc,
		Description:   desc,
		Price:         price,
		ImageURL:      imageURL,
		Model3dUrl:    modelURL,
		Model3DIosUrl: modelIosURL,
		Ordine:        ordine,
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

func (h *MenuHandler) EditCategory(c *gin.Context) {
	id := c.Param("id")
	var category models.Category
	if err := database.DB.First(&category, id).Error; err != nil {
		c.String(http.StatusNotFound, "Categoria non trovata")
		return
	}

	c.HTML(http.StatusOK, "menu_category_edit.html", gin.H{
		"Title":    "Modifica Categoria",
		"Category": category,
	})
}

func (h *MenuHandler) UpdateCategory(c *gin.Context) {
	id := c.Param("id")
	var category models.Category
	if err := database.DB.First(&category, id).Error; err != nil {
		c.String(http.StatusNotFound, "Categoria non trovata")
		return
	}

	category.Name = c.PostForm("name")
	category.Description = c.PostForm("description")
	ordineStr := c.PostForm("ordine")
	ordine, _ := strconv.Atoi(ordineStr)
	category.Ordine = ordine

	file, err := c.FormFile("immagine")
	if err == nil {
		os.MkdirAll("uploads/categories", os.ModePerm)
		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), filepath.Base(file.Filename))
		outPath := fmt.Sprintf("uploads/categories/%s", filename)
		if finalPath, err := services.CompressAndSaveImage(file, outPath); err == nil {
			category.ImageURL = "/" + finalPath
		}
	}

	database.DB.Save(&category)
	c.Redirect(http.StatusSeeOther, "/admin/menu")
}

func (h *MenuHandler) EditProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.Product
	if err := database.DB.First(&product, id).Error; err != nil {
		c.String(http.StatusNotFound, "Prodotto non trovato")
		return
	}

	var categories []models.Category
	database.DB.Find(&categories)

	c.HTML(http.StatusOK, "menu_product_edit.html", gin.H{
		"Title":      "Modifica Prodotto",
		"Product":    product,
		"Categories": categories,
	})
}

func (h *MenuHandler) UpdateProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.Product
	if err := database.DB.First(&product, id).Error; err != nil {
		c.String(http.StatusNotFound, "Prodotto non trovato")
		return
	}

	catIDStr := c.PostForm("category_id")
	catID, _ := strconv.ParseUint(catIDStr, 10, 32)
	product.CategoryID = uint(catID)
	product.Name = c.PostForm("name")
	product.ShortDesc = c.PostForm("short_desc")
	product.Description = c.PostForm("description")
	ordineStr := c.PostForm("ordine")
	ordine, _ := strconv.Atoi(ordineStr)
	product.Ordine = ordine
	if p, err := strconv.ParseFloat(c.PostForm("price"), 64); err == nil {
		product.Price = p
	}

	file3d, err3d := c.FormFile("modello_3d")
	if err3d == nil {
		os.MkdirAll("uploads/models3d", os.ModePerm)
		filename3d := fmt.Sprintf("%d_%s", time.Now().Unix(), filepath.Base(file3d.Filename))
		filepath3d := fmt.Sprintf("uploads/models3d/%s", filename3d)
		if err := c.SaveUploadedFile(file3d, filepath3d); err == nil {
			product.Model3dUrl = "/" + filepath3d
		}
	}

	file3dIos, err3dIos := c.FormFile("modello_3d_ios")
	if err3dIos == nil {
		os.MkdirAll("uploads/models3d", os.ModePerm)
		filename3dIos := fmt.Sprintf("%d_ios_%s", time.Now().Unix(), filepath.Base(file3dIos.Filename))
		filepath3dIos := fmt.Sprintf("uploads/models3d/%s", filename3dIos)
		if err := c.SaveUploadedFile(file3dIos, filepath3dIos); err == nil {
			product.Model3DIosUrl = "/" + filepath3dIos
		}
	}

	file, err := c.FormFile("immagine")
	if err == nil {
		os.MkdirAll("uploads/products", os.ModePerm)
		filename := fmt.Sprintf("%d_%s", time.Now().Unix(), filepath.Base(file.Filename))
		outPath := fmt.Sprintf("uploads/products/%s", filename)
		if finalPath, err := services.CompressAndSaveImage(file, outPath); err == nil {
			product.ImageURL = "/" + finalPath
		}
	}

	database.DB.Save(&product)
	c.Redirect(http.StatusSeeOther, "/admin/menu")
}
