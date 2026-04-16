package models

import (
	"time"

	"gorm.io/gorm"
)

// User rappresenta la tabella "users" nel database
type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Nome      string         `gorm:"size:100;not null" json:"nome"`
	Cognome   string         `gorm:"size:100;not null" json:"cognome"`
	Email     string         `gorm:"size:255;uniqueIndex;not null" json:"email"`
	Password  string         `gorm:"size:255;not null" json:"-"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type Event struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	Titolo      string         `gorm:"size:200;not null" json:"titolo"`
	Descrizione string         `gorm:"type:text;not null" json:"descrizione"`
	ImmagineURL string         `gorm:"type:text" json:"immagine_url"`
	DataEvento  time.Time      `gorm:"type:date;not null" json:"data_evento"`
	Ora         string         `gorm:"size:10;not null" json:"ora"`
	Luogo       string         `gorm:"size:255" json:"luogo"`
	CreatoDa    *uint          `json:"creato_da"`
	User        User           `gorm:"foreignKey:CreatoDa" json:"-"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

type Offer struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	Titolo       string         `gorm:"size:200;not null" json:"titolo"`
	Descrizione  string         `gorm:"type:text;not null" json:"descrizione"`
	ImmagineURL  string         `gorm:"type:text" json:"immagine_url"`
	ValidaDal    time.Time      `gorm:"not null" json:"valida_dal"`
	ValidaFino   time.Time      `gorm:"not null" json:"valida_fino"`
	CodiceSconto string         `gorm:"size:50" json:"codice_sconto"`
	CreatoDa     *uint          `json:"creato_da"`
	User         User           `gorm:"foreignKey:CreatoDa" json:"-"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}
