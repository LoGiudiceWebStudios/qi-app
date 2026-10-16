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

	start := eventStart(event, now.In(eventLocation))
	return !now.After(start.Add(12 * time.Hour))
}

func eventStart(event models.Event, now time.Time) time.Time {
	year, month, day := event.DataEvento.Date()
	if event.RicorrenzaGiorno >= 0 {
		year, month, day = now.Date()
	}

	start := time.Date(year, month, day, 0, 0, 0, 0, eventLocation)
	clock := strings.TrimSpace(event.Ora)
	for _, layout := range []string{"15:04", "15:04:05"} {
		if parsed, err := time.Parse(layout, clock); err == nil {
			return start.Add(time.Duration(parsed.Hour())*time.Hour + time.Duration(parsed.Minute())*time.Minute + time.Duration(parsed.Second())*time.Second)
		}
	}
	return start
}
