package models

import "time"

type Category struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	Name        string    `json:"name" gorm:"not null"`
	Description string    `json:"description"`
	ImageURL    string    `json:"image_url"`
	Ordine      int       `json:"ordine" gorm:"default:0"`
	Products    []Product `json:"products" gorm:"foreignKey:CategoryID"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
