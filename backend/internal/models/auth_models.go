package models

type RegisterRequest struct {
	Nome     string `json:"nome" binding:"required"`
	Cognome  string `json:"cognome"`
	Telefono string `json:"telefono"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
	FCMToken string `json:"fcm_token,omitempty"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
	FCMToken string `json:"fcm_token,omitempty"`
}

type SocialLoginRequest struct {
	Provider string `json:"provider" binding:"required"` // "google" o "apple"
	SocialID string `json:"social_id" binding:"required"`
	IdToken  string `json:"id_token"` // Add id_token for backend verification
	Email    string `json:"email" binding:"required,email"`
	Nome     string `json:"nome"`
	FCMToken string `json:"fcm_token,omitempty"`
}
