package services

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/models"
)

type HomeService struct {
}

func NewHomeService() *HomeService {
	return &HomeService{}
}

type TimeSlot struct {
	Start string `json:"start"`
	End   string `json:"end"`
}

type WeeklySchedule map[string][]TimeSlot

// padTime Assicura padding zeri per il confronto (es. "9:00" -> "09:00")
func padTime(t string) string {
	if len(t) == 4 { // e.g. "9:00"
		return "0" + t
	}
	return t
}

func getActiveOrUpcomingSlotInfo(nowH string, slots []TimeSlot) (bool, string, string) {
	if len(slots) == 0 {
		return false, "Chiuso", ""
	}

	isOpen := false
	var activeSlot *TimeSlot
	var upcomingSlot *TimeSlot

	for _, slot := range slots {
		s := padTime(slot.Start)
		e := padTime(slot.End)

		// Check if active
		if s > e {
			if nowH >= s || nowH < e {
				isOpen = true
				if activeSlot == nil {
					activeSlot = &slot
				}
			}
		} else {
			if nowH >= s && nowH < e {
				isOpen = true
				if activeSlot == nil {
					activeSlot = &slot
				}
			}
		}

		// Check if upcoming
		if s >= nowH && upcomingSlot == nil {
			upcomingSlot = &slot
		}
	}

	if activeSlot != nil {
		return isOpen, padTime(activeSlot.Start), padTime(activeSlot.End)
	}
	if upcomingSlot != nil {
		return isOpen, padTime(upcomingSlot.Start), padTime(upcomingSlot.End)
	}

	// fallback to first slot
	return isOpen, padTime(slots[0].Start), padTime(slots[0].End)
}

// GetHomeData fetch from database
func (s *HomeService) GetHomeData() (*models.HomeData, error) {

	var forcedStatus models.Setting
	database.DB.Where("key = ?", "forced_status").Attrs(models.Setting{Value: "auto"}).FirstOrCreate(&forcedStatus)

	var venueScheduleSet models.Setting
	database.DB.Where("key = ?", "venue_schedule").Attrs(models.Setting{Value: `{"monday":[],"tuesday":[],"wednesday":[],"thursday":[],"friday":[],"saturday":[],"sunday":[]}`}).FirstOrCreate(&venueScheduleSet)

	var forcedKitchenStatus models.Setting
	database.DB.Where("key = ?", "forced_kitchen_status").Attrs(models.Setting{Value: "auto"}).FirstOrCreate(&forcedKitchenStatus)

	var kitchenScheduleSet models.Setting
	database.DB.Where("key = ?", "kitchen_schedule").Attrs(models.Setting{Value: `{"monday":[],"tuesday":[],"wednesday":[],"thursday":[],"friday":[],"saturday":[],"sunday":[]}`}).FirstOrCreate(&kitchenScheduleSet)

	loc, _ := time.LoadLocation("Europe/Rome")
	nowT := time.Now().In(loc)
	nowH := nowT.Format("15:04")
	currentDay := strings.ToLower(nowT.Weekday().String())

	var venueSchedule WeeklySchedule
	json.Unmarshal([]byte(venueScheduleSet.Value), &venueSchedule)

	var kitchenSchedule WeeklySchedule
	json.Unmarshal([]byte(kitchenScheduleSet.Value), &kitchenSchedule)

	venueDaySlots := venueSchedule[currentDay]
	kitchenDaySlots := kitchenSchedule[currentDay]

	isVenueOpenTime, opTime, clTime := getActiveOrUpcomingSlotInfo(nowH, venueDaySlots)
	isKitchenOpenTime, kopTime, kclTime := getActiveOrUpcomingSlotInfo(nowH, kitchenDaySlots)

	isOpen := false
	isKitchenOpen := false

	if forcedStatus.Value == "open" {
		isOpen = true
	} else if forcedStatus.Value == "closed" {
		isOpen = false
	} else {
		isOpen = isVenueOpenTime
	}

	if forcedKitchenStatus.Value == "open" {
		isKitchenOpen = true
	} else if forcedKitchenStatus.Value == "closed" {
		isKitchenOpen = false
	} else {
		isKitchenOpen = isKitchenOpenTime
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
		OpeningTime:        opTime,
		ClosingTime:        clTime,
		IsKitchenOpen:      isKitchenOpen,
		KitchenOpeningTime: kopTime,
		KitchenClosingTime: kclTime,
		LocationName:       "Via Luigi Einaudi, 18",
		NextEvent:          nextEventTitle,
		Events:             homeEvents,
		Offers:             homeOffers,
	}, nil
}
