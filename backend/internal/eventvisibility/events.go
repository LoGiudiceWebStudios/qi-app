package eventvisibility

import (
	"strings"
	"time"

	"qi-backend/internal/models"
)

var eventLocation = func() *time.Location {
	location, err := time.LoadLocation("Europe/Rome")
	if err != nil {
		return time.Local
	}
	return location
}()

func IsActive(event models.Event, now time.Time) bool {
	if !event.CreatedAt.IsZero() && now.Before(event.CreatedAt) {
		return false
	}

	nowInLoc := now.In(eventLocation)
	if event.RicorrenzaGiorno >= 0 && event.RicorrenzaGiorno <= 6 {
		return true
	}

	start := eventStart(event.DataEvento, event.Ora)
	return !nowInLoc.After(start.Add(12 * time.Hour))
}

// EffectiveDate restituisce la data dell'evento per gli eventi singoli,
// oppure la prossima occorrenza utile per gli eventi ricorrenti (mantenendo
// la data di oggi/ieri finché non sono passate 12 ore dall'orario dell'evento).
func EffectiveDate(event models.Event, now time.Time) time.Time {
	nowInLoc := now.In(eventLocation)
	if event.RicorrenzaGiorno < 0 || event.RicorrenzaGiorno > 6 {
		year, month, day := event.DataEvento.Date()
		return time.Date(year, month, day, 0, 0, 0, 0, eventLocation)
	}

	today := time.Date(nowInLoc.Year(), nowInLoc.Month(), nowInLoc.Day(), 0, 0, 0, 0, eventLocation)
	for offset := -1; offset <= 7; offset++ {
		candidateDay := today.AddDate(0, 0, offset)
		if int(candidateDay.Weekday()) != event.RicorrenzaGiorno {
			continue
		}
		start := eventStart(candidateDay, event.Ora)
		if !nowInLoc.After(start.Add(12 * time.Hour)) {
			return candidateDay
		}
	}
	return today
}

func eventStart(date time.Time, rawClock string) time.Time {
	year, month, day := date.Date()
	start := time.Date(year, month, day, 0, 0, 0, 0, eventLocation)
	clock := strings.TrimSpace(rawClock)
	for _, layout := range []string{"15:04", "15:04:05"} {
		if parsed, err := time.Parse(layout, clock); err == nil {
			return start.Add(time.Duration(parsed.Hour())*time.Hour + time.Duration(parsed.Minute())*time.Minute + time.Duration(parsed.Second())*time.Second)
		}
	}
	return start
}
