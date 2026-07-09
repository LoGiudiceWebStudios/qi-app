package main

import (
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"

	"qi-backend/internal/database"
	"qi-backend/internal/handlers"
	"qi-backend/internal/handlers/admin"
	"qi-backend/internal/middleware"
	"qi-backend/internal/models"
	"qi-backend/internal/services"
)

func main() {
	log.Println("Inizializzazione del database...")
	database.Connect()

	middleware.InitMimeTypes()

	log.Println("Inizializzazione di Firebase e Cron Jobs...")
	services.InitFirebase()
	services.StartCronJobs()

	homeService := services.NewHomeService()
	homeHandler := handlers.NewHomeHandler(homeService)
	authService := services.NewAuthService()
	authHandler := handlers.NewAuthHandler(authService)

	adminAuthHandler := admin.NewAdminAuthHandler(authService)
	adminDashboardHandler := admin.NewDashboardHandler()
	adminEventsHandler := admin.NewEventsHandler()
	adminOffersHandler := admin.NewOffersHandler()
	adminMenuHandler := admin.NewMenuHandler()
	adminNotificationsHandler := admin.NewNotificationsHandler()
	adminPointsHandler := admin.NewPointsHandler()
	adminRewardsHandler := admin.NewRewardsHandler()
	adminUsersHandler := admin.NewUsersHandler()
	userPointsHandler := handlers.NewUserPointsHandler()

	router := gin.Default()
	router.Use(middleware.CORSMiddleware())
	router.Static("/uploads", "./uploads")

	router.LoadHTMLGlob("internal/templates/admin/*.html")

	router.GET("/", func(c *gin.Context) {
		c.Redirect(http.StatusMovedPermanently, "/admin")
	})

	api := router.Group("/api/v1")
	{
		api.POST("/auth/login", authHandler.Login)
		api.POST("/auth/signup", authHandler.RequestSignUp)
		api.POST("/auth/verify-signup", authHandler.VerifySignUp)
		api.POST("/auth/social", authHandler.SocialLogin)
		api.POST("/auth/forgot-password", handlers.ForgotPassword)
		api.POST("/auth/verify-reset-code", handlers.VerifyResetCode)
		api.POST("/auth/reset-password", handlers.ResetPassword)
		api.GET("/home", homeHandler.GetHomeData)
		api.GET("/offers", handlers.GetOffers)
		api.GET("/events", handlers.GetEvents)
		api.GET("/rewards", handlers.GetRewards)

		private := api.Group("/")
		private.Use(middleware.JWTAuth())
		{
			private.GET("/profile", authHandler.GetProfile)
			private.POST("/profile/update", authHandler.UpdateProfile)
			private.DELETE("/profile", authHandler.DeleteAccount)
			private.POST("/events", handlers.CreateEvent)
			private.POST("/auth/fcm_token", authHandler.UpdateFCMToken)
			private.POST("/offers/:id/generate", handlers.GenerateOfferCode)
			private.POST("/points/claim", userPointsHandler.ClaimPoints)
		}

		api.GET("/categories", adminMenuHandler.ListCategoriesAPI)
		api.GET("/categories/:id/products", adminMenuHandler.GetCategoryProductsAPI)
	}

	backoffice := router.Group("/admin")
	{
		backoffice.GET("/login", adminAuthHandler.RenderLogin)
		backoffice.POST("/login", adminAuthHandler.Login)
		backoffice.GET("/logout", adminAuthHandler.Logout)

		protected := backoffice.Group("/")
		protected.Use(middleware.AdminAuthCookie())
		{
			protected.GET("", adminDashboardHandler.RenderDashboard)
			protected.POST("/logout-all", adminDashboardHandler.ForceLogoutAll)
			protected.POST("/offers/validate", handlers.ValidateOfferCode)
			protected.POST("/settings", adminDashboardHandler.UpdateSettings)
			protected.GET("/events", adminEventsHandler.RenderEvents)
			protected.GET("/events/new", adminEventsHandler.RenderNewEvent)
			protected.POST("/events", adminEventsHandler.CreateEvent)
			protected.GET("/events/:id/edit", adminEventsHandler.RenderEditEvent)
			protected.POST("/events/:id/edit", adminEventsHandler.UpdateEvent)
			protected.POST("/events/:id/delete", adminEventsHandler.DeleteEvent)
			protected.GET("/offers", adminOffersHandler.List)
			protected.GET("/offers/new", adminOffersHandler.CreateGet)
			protected.POST("/offers", adminOffersHandler.CreatePost)
			protected.GET("/offers/:id/edit", adminOffersHandler.EditGet)
			protected.POST("/offers/:id/edit", adminOffersHandler.UpdatePost)
			protected.POST("/offers/:id/delete", adminOffersHandler.Delete)
			protected.GET("/menu", adminMenuHandler.RenderMenu)
			protected.POST("/menu/categories", adminMenuHandler.CreateCategory)
			protected.GET("/menu/categories/:id/edit", adminMenuHandler.EditCategory)
			protected.POST("/menu/categories/:id/edit", adminMenuHandler.UpdateCategory)
			protected.POST("/menu/categories/:id/delete", adminMenuHandler.DeleteCategory)
			protected.POST("/menu/products", adminMenuHandler.CreateProduct)
			protected.GET("/menu/products/:id/edit", adminMenuHandler.EditProduct)
			protected.POST("/menu/products/:id/edit", adminMenuHandler.UpdateProduct)
			protected.POST("/menu/products/:id/delete", adminMenuHandler.DeleteProduct)
			protected.GET("/users", adminUsersHandler.HandleIndex)
			protected.GET("/notifications", adminNotificationsHandler.Index)
			protected.POST("/notifications", adminNotificationsHandler.SendPost)
			protected.POST("/notifications/schedule", adminNotificationsHandler.SchedulePost)
			protected.POST("/notifications/schedule/:id/delete", adminNotificationsHandler.DeleteSchedule)
			protected.GET("/points", adminPointsHandler.RenderPointsPage)
			protected.POST("/points/generate", adminPointsHandler.GeneratePointsQRCode)
			protected.POST("/points/deduct", adminPointsHandler.DeductPoints)
			protected.GET("/points/user/:id", adminPointsHandler.GetUserPoints)
			protected.GET("/rewards", adminRewardsHandler.List)
			protected.GET("/rewards/new", adminRewardsHandler.CreateGet)
			protected.POST("/rewards", adminRewardsHandler.CreatePost)
			protected.POST("/rewards/:id/delete", adminRewardsHandler.Delete)
		}
	}

	log.Println("Avvio server backend per Qi in corso sulla porta :9090...")
	if err := router.Run(":9090"); err != nil {
		log.Fatalf("Errore critico in avvio server HTTP: %v", err)
	}
}

func seedUsers() {
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)

	var user models.User
	if err := database.DB.Where("email = ?", "test@qiapp.com").First(&user).Error; err != nil {
		testUser := models.User{Nome: "Mario", Cognome: "Rossi", Email: "test@qiapp.com", Password: string(hashedPassword), Ruolo: "user"}
		database.DB.Create(&testUser)
		log.Println("Utente APP creato: test@qiapp.com / password123")
	}

	var admin models.User
	if err := database.DB.Where("email = ?", "admin@qiapp.com").First(&admin).Error; err != nil {
		adminUser := models.User{Nome: "Admin", Cognome: "Server", Email: "admin@qiapp.com", Password: string(hashedPassword), Ruolo: "admin"}
		database.DB.Create(&adminUser)
		log.Println("Utente ADMIN creato: admin@qiapp.com / password123")
	}
}

func seedOffers() {
	var count int64
	if database.DB.Model(&models.Offer{}).Count(&count); count > 0 {
		return
	}
	now := time.Now()
	offers := []models.Offer{
		{Titolo: "Get Flat 25 off", Descrizione: "Save 25 on all transactions...", ImmagineURL: "https://picsum.photos/seed/1/1200/700", ValidaDal: now.AddDate(0, 0, -7), ValidaFino: now.AddDate(0, 0, 30), CodiceSconto: "QI25OFF"},
	}
	database.DB.Create(&offers)
}
