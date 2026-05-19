package models

import "gorm.io/gorm"

// Setting rappresenta le impostazioni globali dell'app/locale (come orari, forzature, ecc)
type Setting struct {
	gorm.Model
	Key   string `gorm:"uniqueIndex;not null" json:"key"` // es. "opening_hours"
	Value string `json:"value"`                           // Valore in JSON testuale per flessibilità o semplice testo
}
