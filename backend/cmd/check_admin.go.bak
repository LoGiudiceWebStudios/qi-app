package main

import (
"fmt"
"qi-backend/internal/database"
"qi-backend/internal/models"
)

func main() {
database.Connect()
var user models.User
if err := database.DB.Where("email = ?", "admin@qiapp.com").First(&user).Error; err != nil {
fmt.Println("Errore:", err)
return
}
fmt.Printf("User: %+v\n", user)
}
