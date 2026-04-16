package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"

	"qi-backend/internal/database"
	"qi-backend/internal/handlers"
	"qi-backend/internal/handlers/admin"
	"qi-backend/internal/services"
)

func main() {
	// Connessione al DB Postgres 'qi_db'
	log.Println("Inizializzazione del database...")
	database.Connect()

	// 1. Inizializzo service e handlers (Dependency Injection)
	homeService := services.NewHomeService()
	homeHandler := handlers.NewHomeHandler(homeService)
	adminDashboardHandler := admin.NewDashboardHandler()
	adminEventsHandler := admin.NewEventsHandler()

	// 2. Inizializzazione Router Gin
	router := gin.Default()

	// Servire la cartella di upload pubblicamente
	router.Static("/uploads", "./uploads")

	// Redirect root to admin dashboard
	router.GET("/", func(c *gin.Context) {
		c.Redirect(http.StatusMovedPermanently, "/admin")
	})

	// (Aggiungi middleware qui se necessario come ad esempio CORS middlewares)

	// 3. Caricamento dei Template HTML (Glob per caricare sia base che viste specifiche)
	router.LoadHTMLGlob("internal/templates/admin/*.html")

	// 4. Configurazione Gruppi di Rotte REST API (JSON)
	api := router.Group("/api/v1")
	{
		// Rotte pubbliche per Flutter
		api.GET("/home", homeHandler.GetHomeData)
		api.GET("/events", handlers.GetEvents)
		api.POST("/events", handlers.CreateEvent) // per admin se si usa un'API dal client
	}

	// 5. Gruppo rotte della Dashboard Web Admin (HTML HTMX)
	backoffice := router.Group("/admin")
	{
		// Dashboard principale
		backoffice.GET("", adminDashboardHandler.RenderDashboard)
		backoffice.GET("/events", adminEventsHandler.RenderEvents)
		backoffice.GET("/events/new", adminEventsHandler.RenderNewEvent)
		backoffice.POST("/events", adminEventsHandler.CreateEvent)
	}

	// Avvia il server (di default porta 8080)
	log.Println("Avvio server backend per Qi in corso sulla porta :9090...")
	if err := router.Run(":9090"); err != nil {
		log.Fatalf("Errore critico in avvio server HTTP: %v", err)
	}
}
