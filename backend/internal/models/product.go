package models

import "time"

type Product struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	CategoryID  uint      `json:"category_id" gorm:"not null"`
	Name        string    `json:"name" gorm:"not null"`
	ShortDesc   string    `json:"short_desc"`
	Description string    `json:"description"`
	Price         float64   `json:"price" gorm:"not null"`
	ImageURL      string    `json:"image_url"`
	Model3dUrl    string    `json:"model3d_url"`
	Model3DIosUrl string    `json:"model3d_ios_url"`
	IsAvailable   bool      `json:"is_available" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
