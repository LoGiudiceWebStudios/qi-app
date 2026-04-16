package services

import (
	"qi-backend/internal/models"
)

type HomeService struct {
	// Qui poi ci finirà il DB o repository pattern per leggere dal DB reale
}

func NewHomeService() *HomeService {
	return &HomeService{}
}

// GetHomeData simula per adesso un fetch dal database degli eventi, offerte e orari.
func (s *HomeService) GetHomeData() (*models.HomeData, error) {
	// Mock response che andrà a popolare la Home page di Qi
	return &models.HomeData{
		IsOpen:       true,
		ClosingTime:  "02:00",
		LocationName: "Via Luigi Enaudi",
		NextEvent:    "Karaoke Night",
		Events: []models.HomeEvent{
			{ID: "1", Title: "Serata DJ Set", ImageUrl: "", Date: "2026-04-18"},
			{ID: "2", Title: "Degustazione Birre", ImageUrl: "", Date: "2026-04-20"},
			{ID: "3", Title: "Karaoke Night", ImageUrl: "", Date: "2026-04-22"},
		},
		Offers: []models.HomeOffer{
			{ID: "1", Title: "Menu Burger a 10€", ImageUrl: ""},
			{ID: "2", Title: "2x1 Spritz", ImageUrl: ""},
		},
	}, nil
}
