package main
import (
"fmt"
"qi-backend/internal/database"
"qi-backend/internal/models"
)
func main() {
	database.Connect()
	var settings []models.Setting
	database.DB.Unscoped().Find(&settings)
	for _, s := range settings {
		fmt.Printf("id: %d, key: '%s', value: '%s'\n", s.ID, s.Key, s.Value)
	}
}
