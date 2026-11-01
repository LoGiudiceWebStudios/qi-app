package services

import (
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"time"

	"qi-backend/internal/database"
	"qi-backend/internal/eventvisibility"
	"qi-backend/internal/models"
	"qi-backend/internal/offervisibility"
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
	eventCutoff := nowT.Add(-12 * time.Hour)
	eventCutoff = time.Date(eventCutoff.Year(), eventCutoff.Month(), eventCutoff.Day(), 0, 0, 0, 0, loc)
	database.DB.Where("data_evento >= ? OR ricorrenza_giorno >= 0", eventCutoff).Order("data_evento asc").Find(&events)

	type homeEventCandidate struct {
		event models.Event
		date  time.Time
	}
	candidates := make([]homeEventCandidate, 0, len(events))
	for _, e := range events {
		if !eventvisibility.IsActive(e, nowT) {
			continue
		}
		candidates = append(candidates, homeEventCandidate{
			event: e,
			date:  eventvisibility.EffectiveDate(e, nowT),
		})
	}
	sort.SliceStable(candidates, func(i, j int) bool {
		return candidates[i].date.Before(candidates[j].date)
	})

	var homeEvents []models.HomeEvent
	for _, c := range candidates {
		homeEvents = append(homeEvents, models.HomeEvent{
			ID:       fmt.Sprint(c.event.ID),
			Title:    c.event.Titolo,
			ImageUrl: c.event.ImmagineURL,
			Date:     c.date.Format("2006-01-02"),
		})
	}
	if len(homeEvents) == 0 {
		homeEvents = []models.HomeEvent{}
	}

	// Recuperiamo offerte
	var offers []models.Offer
	nowOff := time.Now()
	startOfDayOff := time.Date(nowOff.Year(), nowOff.Month(), nowOff.Day(), 0, 0, 0, 0, nowOff.Location())
	database.DB.Where("valida_fino >= ?", startOfDayOff).Order("valida_dal asc, valida_fino asc, id asc").Find(&offers)
	type homeOfferWithStatus struct {
		offer  models.Offer
		status offervisibility.Status
	}
	visibleOffers := make([]homeOfferWithStatus, 0, len(offers))
	for _, offer := range offers {
		status := offervisibility.Evaluate(offer, nowOff)
		if status.Visible {
			visibleOffers = append(visibleOffers, homeOfferWithStatus{offer: offer, status: status})
		}
	}
	sort.SliceStable(visibleOffers, func(i, j int) bool {
		if visibleOffers[i].status.Active != visibleOffers[j].status.Active {
			return visibleOffers[i].status.Active
		}
		return visibleOffers[i].status.NextActivationAt.Before(visibleOffers[j].status.NextActivationAt)
	})

	var homeOffers []models.HomeOffer
	for _, item := range visibleOffers {
		o := item.offer
		homeOffers = append(homeOffers, models.HomeOffer{
			ID:              fmt.Sprint(o.ID),
			Title:           o.Titolo,
			ImageUrl:        o.ImmagineURL,
			IsActive:        item.status.Active,
			ActivationLabel: item.status.ActivationLabel,
		})
	}
	if len(homeOffers) == 0 {
		homeOffers = []models.HomeOffer{}
	}

	nextEventTitle := "Nessun evento in programma"
	if len(homeEvents) > 0 {
		nextEventTitle = homeEvents[0].Title
	}

	// Recuperiamo le notifiche/post degli ultimi 7 giorni
	var sentNotifications []models.SentNotification
	weekAgo := nowT.AddDate(0, 0, -7)
	database.DB.Where("created_at >= ?", weekAgo).Order("created_at desc, id desc").Limit(20).Find(&sentNotifications)
	homePosts := make([]models.HomePost, 0, len(sentNotifications))
	for _, n := range sentNotifications {
		createdLocal := n.CreatedAt.In(loc)
		homePosts = append(homePosts, models.HomePost{
			ID:        fmt.Sprint(n.ID),
			Title:     n.Title,
			Message:   n.Message,
			CreatedAt: createdLocal.Format("02/01 · 15:04"),
		})
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
		Posts:              homePosts,
	}, nil
}
