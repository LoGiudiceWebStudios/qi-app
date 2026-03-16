package models

import (
	"time"

	"gorm.io/gorm"
)

// User rappresenta la tabella "users" nel database
type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Email     string         `gorm:"uniqueIndex;not null" json:"email"`
	Password  string         `gorm:"not null" json:"-"` // Il "-" impedisce che la password venga esposta nelle risposte JSON
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"` // Per il soft-delete di GORM
}
