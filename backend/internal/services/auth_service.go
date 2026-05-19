package services

import (
    "context"
    "errors"
    "os"
    "time"

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

// GenerateJWT crea un token con l'ID dell'utente che scade dopo 72 ore
func (s *AuthService) GenerateJWT(userID uint) (string, error) {
    secret := os.Getenv("JWT_SECRET")
    if secret == "" {
        secret = "my_super_secret_key_change_me" // Fallback allineato con il middleware
    }

    claims := jwt.MapClaims{
        "sub": userID,
        "exp": time.Now().Add(time.Hour * 72).Unix(),
        "iat": time.Now().Unix(),
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

func (s *AuthService) SignUp(req models.RegisterRequest) (string, *models.User, error) {
    var existing models.User

    if err := database.DB.Where("email = ?", req.Email).First(&existing).Error; err == nil {
        return "", nil, errors.New("questa email risulta gia in uso")
    } else if !errors.Is(err, gorm.ErrRecordNotFound) {
        return "", nil, err
    }

    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        return "", nil, errors.New("errore durante lhashing della password")
    }

    newUser := models.User{
        Nome:     req.Nome,
        Cognome:  req.Cognome,
        Telefono: req.Telefono,
        Email:    req.Email,
        Password: string(hashedPassword),
        Provider: "email",
        FCMToken: req.FCMToken,
    }

    if err := database.DB.Create(&newUser).Error; err != nil {
        return "", nil, errors.New("errore durante la creazione dell'utente")
    }

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

    err := database.DB.Where("email = ?", req.Email).First(&user).Error
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
