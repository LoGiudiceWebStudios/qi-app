package main

import (
"log"

"golang.org/x/crypto/bcrypt"
"qi-backend/internal/database"
"qi-backend/internal/models"
)

func main() {
database.Connect()

hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)

database.DB.Model(&models.User{}).Where("email IN ?", []string{"test@qiapp.com", "admin@qiapp.com"}).Update("password", string(hashedPassword))
database.DB.Model(&models.User{}).Where("email = ?", "admin@qiapp.com").Update("ruolo", "admin")

log.Println("Password e Ruoli degli utenti di test resettati correttamente!")
}
