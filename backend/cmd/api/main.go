package main

import (
	"log"

	"qi-backend/internal/database"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Inizializza la connessione e le migrazioni del DB
	log.Println("Inizializzazione del database...")
	database.Connect()

	// 2. Configura il Router
	r := gin.Default()

	// 3. Configura il CORS (Fondamentale se il frontend è Web, ma utile anche per il mobile in debug)
	r.Use(cors.Default())

	// 4. Architettura delle Rotte (Versione API v1)
	api := r.Group("/api/v1")
	{
		// 🟢 Rotte Pubbliche
		public := api.Group("/")
		{
			public.GET("/ping", func(c *gin.Context) {
				c.JSON(200, gin.H{
					"status":  "ok",
					"message": "Il Backend di QI App è operativo!",
				})
			})
			// Esempio futuro: public.POST("/login", authHandler.Login)
		}

		// 🔴 Rotte Private (Qui in futuro aggiungeremo un Middleware per verificare il Token)
		private := api.Group("/secure")
		// private.Use(middleware.RequireAuth) // <-- Da implementare in futuro
		{
			private.GET("/profile", func(c *gin.Context) {
				c.JSON(200, gin.H{
					"message": "Benvenuto nell'area protetta",
				})
			})
		}
	}

	// 5. Avvia il server
	log.Println("🚀 Server in ascolto sulla porta 8080...")
	if err := r.Run(":8080"); err != nil {
		log.Fatal("❌ Errore critico all'avvio del server: ", err)
	}
}
