package services

import (
	"errors"
	"qi-backend/internal/database"
	"qi-backend/internal/models"
	// "golang.org/x/crypto/bcrypt" - Per ora simuliamo senza bcrypt o token complessi per velocizzare, andrà decommentato in futuro.
)

type AuthService struct{}

func NewAuthService() *AuthService {
	return &AuthService{}
}

// Login elabora testualmente il tentativo
func (s *AuthService) Login(email, password string) (string, *models.User, error) {
	var user models.User

	// Ricerca l'utente per email
	if err := database.DB.Where("email = ?", email).First(&user).Error; err != nil {
		return "", nil, errors.New("Credenziali non valide o utente inesistente")
	}

	// Simulazione Check delle password in chiaro (in locale metti bcrypyt.CompareHashAndPassword)
	if user.Password != password {
		return "", nil, errors.New("Password errata")
	}

	// Ritorna un finto Token, da sostituire con libreria jwt-go
	fakeToken := "jwt-simulato-12345qwe"

	return fakeToken, &user, nil
}

func (s *AuthService) SignUp(nome, cognome, email, password string) (*models.User, error) {
	var existing models.User

	database.DB.Where("email = ?", email).First(&existing)
	if existing.ID != 0 {
		return nil, errors.New("Questa email risulta già in uso")
	}

	// Simulazione: Hash della password (da inserire successivamente via bcrypt)
	// hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), 14)

	newUser := models.User{
		Nome:     nome,
		Cognome:  cognome,
		Email:    email,
		Password: password, // Metti hashedPassword qui in prod
	}

	if err := database.DB.Create(&newUser).Error; err != nil {
		return nil, errors.New("Errore interno durante il salvataggio utente")
	}

	return &newUser, nil
}
