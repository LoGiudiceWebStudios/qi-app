package services

import (
	"fmt"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

type HomeService struct {
}

func NewHomeService() *HomeService {
	return &HomeService{}
}

// GetHomeData fetch from database
func (s *HomeService) GetHomeData() (*models.HomeData, error) {

	var forcedStatus models.Setting
	database.DB.Where("key = ?", "forced_status").Attrs(models.Setting{Value: "auto"}).FirstOrCreate(&forcedStatus)

	var closingTime models.Setting
	database.DB.Where("key = ?", "closing_time").Attrs(models.Setting{Value: "02:00"}).FirstOrCreate(&closingTime)

	var openingTime models.Setting
	database.DB.Where("key = ?", "opening_time").Attrs(models.Setting{Value: "18:00"}).FirstOrCreate(&openingTime)

	var forcedKitchenStatus models.Setting
	database.DB.Where("key = ?", "forced_kitchen_status").Attrs(models.Setting{Value: "auto"}).FirstOrCreate(&forcedKitchenStatus)

	var kitchenOpeningTime models.Setting
	database.DB.Where("key = ?", "kitchen_opening_time").Attrs(models.Setting{Value: "19:00"}).FirstOrCreate(&kitchenOpeningTime)

	var kitchenClosingTime models.Setting
	database.DB.Where("key = ?", "kitchen_closing_time").Attrs(models.Setting{Value: "23:00"}).FirstOrCreate(&kitchenClosingTime)

	isOpen := false
	isKitchenOpen := false
	loc, _ := time.LoadLocation("Europe/Rome")
	nowH := time.Now().In(loc).Format("15:04")
	// Assicure padding zeri per il confronto (es. "9:00" -> "09:00")
	padTime := func(t string) string {
		if len(t) == 4 { // e.g. "9:00"
			return "0" + t
		}
		return t
	}

	opTime := padTime(openingTime.Value)
	clTime := padTime(closingTime.Value)
	kopTime := padTime(kitchenOpeningTime.Value)
	kclTime := padTime(kitchenClosingTime.Value)

	if forcedStatus.Value == "open" {
		isOpen = true
	} else if forcedStatus.Value == "closed" {
		isOpen = false
	} else {
		// Logica auto
		if opTime > clTime {
			if nowH >= opTime || nowH < clTime {
				isOpen = true
			}
		} else {
			if nowH >= opTime && nowH < clTime {
				isOpen = true
			}
		}
	}

	if forcedKitchenStatus.Value == "open" {
		isKitchenOpen = true
	} else if forcedKitchenStatus.Value == "closed" {
		isKitchenOpen = false
	} else {
		// Logica auto
		if kopTime > kclTime {
			if nowH >= kopTime || nowH < kclTime {
				isKitchenOpen = true
			}
		} else {
			if nowH >= kopTime && nowH < kclTime {
				isKitchenOpen = true
			}
		}
	}

	// Recuperiamo gli eventi
	var events []models.Event
	database.DB.Where("data_evento >= ?", time.Now().Add(-12*time.Hour)).Order("data_evento asc").Limit(3).Find(&events)
	var homeEvents []models.HomeEvent
	for _, e := range events {
		homeEvents = append(homeEvents, models.HomeEvent{
			ID:       fmt.Sprint(e.ID),
			Title:    e.Titolo,
			ImageUrl: e.ImmagineURL,
			Date:     e.DataEvento.Format("2006-01-02"),
		})
	}
	if len(homeEvents) == 0 {
		homeEvents = []models.HomeEvent{}
	}

	// Recuperiamo offerte
	var offers []models.Offer
	nowOff := time.Now()
	startOfDayOff := time.Date(nowOff.Year(), nowOff.Month(), nowOff.Day(), 0, 0, 0, 0, nowOff.Location())
	database.DB.Where("valida_dal <= ? AND valida_fino >= ?", nowOff, startOfDayOff).Limit(3).Find(&offers)
	var homeOffers []models.HomeOffer
	for _, o := range offers {
		homeOffers = append(homeOffers, models.HomeOffer{
			ID:       fmt.Sprint(o.ID),
			Title:    o.Titolo,
			ImageUrl: o.ImmagineURL,
		})
	}
	if len(homeOffers) == 0 {
		homeOffers = []models.HomeOffer{}
	}

	nextEventTitle := "Nessun evento in programma"
	if len(homeEvents) > 0 {
		nextEventTitle = homeEvents[0].Title
	}

	return &models.HomeData{
		IsOpen:             isOpen,
		OpeningTime:        openingTime.Value,
		ClosingTime:        closingTime.Value,
		IsKitchenOpen:      isKitchenOpen,
		KitchenOpeningTime: kitchenOpeningTime.Value,
		KitchenClosingTime: kitchenClosingTime.Value,
		LocationName:       "Via Luigi Einaudi, 18",
		NextEvent:          nextEventTitle,
		Events:             homeEvents,
		Offers:             homeOffers,
	}, nil
}
