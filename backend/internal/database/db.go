package database

import (
	"fmt"
	"log"
	"os"

	"qi-backend/internal/models"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	// 1. Carica il file .env per la sicurezza!
	err := godotenv.Load(".env")
	if err != nil {
		// Log.Println invece di Fatalf, così se siamo in produzione dentro Docker
		// (dove non c'è il file .env ma le variabili native) andrà avanti lo stesso
		log.Println("Nessun file .env trovato, userò le variabili d'ambiente di sistema")
	}

	// 2. Preleviamo i dati in modo SICURO dalle variabili di ambiente
	host := os.Getenv("DB_HOST")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")
	port := os.Getenv("DB_PORT")
	sslmode := os.Getenv("DB_SSLMODE")

	// Costruzione stringa di connessione DSN dinamicamente
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		host, user, password, dbname, port, sslmode)

	// 3. Connessione a PostgreSQL
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("❌ Impossibile connettersi al database %s: %v", dbname, err)
	}

	log.Printf("✅ Connessione al database postgres (%s) riuscita!\n", dbname)

	// 4. Auto-Migrate: Crea in modo sicuro o aggiorna le tabelle nel DB se non esistono
	// Dato che in home_page l'utente si aspetta eventi e offerte, prepariamo le migrazioni

	log.Println("Sincronizzazione tabelle (AutoMigrate)...")
	err = db.AutoMigrate(
		&models.User{},
		&models.Event{},
		&models.Offer{},
	)
	if err != nil {
		log.Fatalf("❌ Errore durante l'automigrazione: %v", err)
	}

	// Correzione DB (per pulire il vecchio schema incastrato che causava l'errore SQLSTATE 23502)
	db.Exec("ALTER TABLE events DROP COLUMN IF EXISTS ora_evento;")

	DB = db
}
