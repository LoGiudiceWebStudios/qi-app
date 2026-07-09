package services

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"

	"gopkg.in/gomail.v2"

	"qi-backend/internal/database"
	"qi-backend/internal/models"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"google.golang.org/api/idtoken"
	"gorm.io/gorm"
)

type AuthService struct{}

func NewAuthService() *AuthService {
	return &AuthService{}
}

func getCurrentAuthVersion() int {
	var setting models.Setting
	if err := database.DB.Where("key = ?", "auth_version").First(&setting).Error; err != nil {
		database.DB.Create(&models.Setting{Key: "auth_version", Value: "1"})
		return 1
	}

	version, err := strconv.Atoi(setting.Value)
	if err != nil || version < 1 {
		return 1
	}

	return version
}

// GenerateJWT crea un token con l'ID dell'utente che scade dopo 365 giorni
func (s *AuthService) GenerateJWT(userID uint) (string, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "d8f9e0a2b4c6d8e0f1a3b5c7d9e1f3a5b7c9d1e3f5a7b9c1d3e5f7a9b1c3d5e7" // Fallback allineato con il middleware
	}

	claims := jwt.MapClaims{
		"sub": userID,
		"exp": time.Now().Add(time.Hour * 24 * 365).Unix(),
		"iat": time.Now().Unix(),
		"ver": getCurrentAuthVersion(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

func (s *AuthService) Login(req models.LoginRequest) (string, *models.User, error) {
	var user models.User

	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", nil, errors.New("credenziali non valide")
		}
		return "", nil, err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return "", nil, errors.New("credenziali non valide")
	}

	if req.FCMToken != "" && req.FCMToken != user.FCMToken {
		user.FCMToken = req.FCMToken
		database.DB.Save(&user)
	}

	token, err := s.GenerateJWT(user.ID)
	if err != nil {
		return "", nil, errors.New("errore durante la generazione del token")
	}

	return token, &user, nil
}

func sendSignupEmail(to, code string) {
	host := os.Getenv("SMTP_HOST")
	portStr := os.Getenv("SMTP_PORT")
	user := os.Getenv("SMTP_USER")
	pass := os.Getenv("SMTP_PASSWORD")

	if host == "" || pass == "" {
		fmt.Println("SMTP credenziali non configurate per signup")
		return
	}

	port, _ := strconv.Atoi(portStr)

	m := gomail.NewMessage()
	m.SetHeader("From", user)
	m.SetHeader("To", to)
	m.SetHeader("Subject", "Codice di Verifica - Qi App")
	m.SetBody("text/plain", fmt.Sprintf("Benvenuto in Qi App!\n\nIl tuo codice di verifica per completare la registrazione è: %s\n\nAttenzione: il codice scade tra 15 minuti.", code))

	d := gomail.NewDialer(host, port, user, pass)
	if err := d.DialAndSend(m); err != nil {
		fmt.Println("Errore nell'invio dell'email: ", err)
	}
}

func (s *AuthService) RequestSignUp(req models.RegisterRequest) error {
	var existing models.User

	if err := database.DB.Where("email = ?", req.Email).First(&existing).Error; err == nil {
		return errors.New("questa email risulta gia in uso")
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return err
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return errors.New("errore durante lhashing della password")
	}

	var pending models.PendingRegistration
	if err := database.DB.Where("email = ?", req.Email).First(&pending).Error; err == nil {
		database.DB.Delete(&pending)
	}

	rand.Seed(time.Now().UnixNano())
	code := fmt.Sprintf("%04d", rand.Intn(10000))
	expiresAt := time.Now().Add(15 * time.Minute)

	newPending := models.PendingRegistration{
		Nome:      req.Nome,
		Cognome:   req.Cognome,
		Telefono:  req.Telefono,
		Email:     req.Email,
		Password:  string(hashedPassword),
		Code:      code,
		ExpiresAt: expiresAt,
	}

	if err := database.DB.Create(&newPending).Error; err != nil {
		return errors.New("errore durante la creazione della richiesta di registrazione")
	}

	go sendSignupEmail(req.Email, code)
	return nil
}

func (s *AuthService) VerifySignUp(email string, code string, fcmToken string) (string, *models.User, error) {
	var pending models.PendingRegistration

	if err := database.DB.Where("email = ? AND code = ?", email, code).First(&pending).Error; err != nil {
		return "", nil, errors.New("codice errato o scaduto")
	}

	if time.Now().After(pending.ExpiresAt) {
		return "", nil, errors.New("codice errato o scaduto")
	}

	newUser := models.User{
		Nome:     pending.Nome,
		Cognome:  pending.Cognome,
		Telefono: pending.Telefono,
		Email:    pending.Email,
		Password: pending.Password,
		Provider: "email",
		FCMToken: fcmToken,
	}

	if err := database.DB.Create(&newUser).Error; err != nil {
		return "", nil, errors.New("errore durante la creazione dell'utente")
	}

	// Delete pending registration after success
	database.DB.Delete(&pending)

	token, err := s.GenerateJWT(newUser.ID)
	if err != nil {
		return "", nil, errors.New("errore durante la generazione del token")
	}

	return token, &newUser, nil
}

// SocialLogin cerca l'utente. Se non esiste, lo crea al volo basandosi sui dati del Social Provider.
func (s *AuthService) SocialLogin(req models.SocialLoginRequest) (string, *models.User, error) {
	var user models.User

	if req.Provider == "google" {
		if req.IdToken == "" {
			return "", nil, errors.New("id token mancante per google login")
		}
		payload, err := idtoken.Validate(context.Background(), req.IdToken, "")
		if err != nil {
			return "", nil, errors.New("token google non valido o scaduto: " + err.Error())
		}
		if email, ok := payload.Claims["email"].(string); ok {
			if email != req.Email {
				req.Email = email // Usa l'email fidata del token
			}
		}
	}

	// Cerca prima per ID social
	err := database.DB.Where("social_id = ? AND provider = ?", req.SocialID, req.Provider).First(&user).Error
	if err != nil && errors.Is(err, gorm.ErrRecordNotFound) {
		// Se non lo trova, prova a vedere se esiste già quell'email per collegare l'account
		err = database.DB.Where("email = ?", req.Email).First(&user).Error
	}

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			user = models.User{
				Nome:     req.Nome,
				Email:    req.Email,
				SocialID: &req.SocialID,
				Provider: req.Provider,
				Ruolo:    "user",
				FCMToken: req.FCMToken,
			}
			if dbErr := database.DB.Create(&user).Error; dbErr != nil {
				return "", nil, errors.New("errore durante la creazione dell'account social")
			}
		} else {
			return "", nil, err
		}
	} else {
		updates := map[string]interface{}{}

		if user.SocialID == nil || *user.SocialID != req.SocialID {
			updates["social_id"] = req.SocialID
			updates["provider"] = req.Provider
		}
		if req.FCMToken != "" && user.FCMToken != req.FCMToken {
			updates["fcm_token"] = req.FCMToken
		}

		if len(updates) > 0 {
			database.DB.Model(&user).Updates(updates)
		}
	}

	token, err := s.GenerateJWT(user.ID)
	if err != nil {
		return "", nil, errors.New("errore durante la generazione del token")
	}

	return token, &user, nil
}
func (s *AuthService) GetProfile(userID uint) (*models.User, error) {
	var user models.User
	if err := database.DB.Select("id", "nome", "cognome", "email", "telefono", "ruolo", "punti").First(&user, userID).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (s *AuthService) UpdateProfile(userID uint, nome, cognome, email, password string) error {
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return err
	}
	if nome != "" {
		user.Nome = nome
	}
	if cognome != "" {
		user.Cognome = cognome
	}
	if email != "" {
		user.Email = email
	}
	if password != "" {
		hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			return err
		}
		user.Password = string(hashed)
	}
	return database.DB.Save(&user).Error
}

func (s *AuthService) DeleteAccount(userID uint) error {
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return err
	}

	// Pulizia token push prima della cancellazione account.
	user.FCMToken = ""
	if err := database.DB.Save(&user).Error; err != nil {
		return err
	}

	return database.DB.Delete(&user).Error
}
