package eventvisibility

import (
	"testing"
	"time"

	"qi-backend/internal/models"
)

func TestIsActiveForSingleEvents(t *testing.T) {
	location := eventLocation
	now := time.Date(2026, time.October, 16, 12, 0, 0, 0, location)

	tests := []struct {
		name      string
		date      time.Time
		timeOfDay string
		want      bool
	}{
		{
			name:      "upcoming event is visible",
			date:      time.Date(2026, time.October, 18, 0, 0, 0, 0, time.UTC),
			timeOfDay: "20:30",
			want:      true,
		},
		{
			name:      "event remains visible within twelve hours after start",
			date:      time.Date(2026, time.October, 15, 0, 0, 0, 0, time.UTC),
			timeOfDay: "23:00",
			want:      true,
		},
		{
			name:      "event is hidden after twelve hours",
			date:      time.Date(2026, time.October, 15, 0, 0, 0, 0, time.UTC),
			timeOfDay: "23:00",
			want:      false,
		},
	}

	for index, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			eventNow := now
			if index == 1 {
				eventNow = time.Date(2026, time.October, 16, 10, 59, 0, 0, location)
			} else if index == 2 {
				eventNow = time.Date(2026, time.October, 16, 11, 1, 0, 0, location)
			}

			event := models.Event{
				DataEvento:       test.date,
				Ora:              test.timeOfDay,
				RicorrenzaGiorno: -1,
				CreatedAt:        eventNow.Add(-time.Hour),
			}
			if got := IsActive(event, eventNow); got != test.want {
				t.Fatalf("IsActive() = %v, want %v", got, test.want)
			}
		})
	}
}

func TestRecurringEventIsVisibleEveryDay(t *testing.T) {
	location := eventLocation
	now := time.Date(2026, time.October, 16, 12, 0, 0, 0, location)
	event := models.Event{
		DataEvento:       time.Date(2026, time.January, 1, 0, 0, 0, 0, time.UTC),
		Ora:              "09:00",
		RicorrenzaGiorno: 1,
		CreatedAt:        now.Add(-24 * time.Hour),
	}

	if !IsActive(event, now) {
		t.Fatal("expected recurring event to be active within twelve hours of today's occurrence")
	}

	nextDay := time.Date(2026, time.October, 17, 8, 0, 0, 0, location)
	if !IsActive(event, nextDay) {
		t.Fatal("expected recurring event to be visible the following day")
	}

	afterOccurrenceWindow := time.Date(2026, time.October, 17, 21, 1, 0, 0, location)
	if IsActive(event, afterOccurrenceWindow) {
		t.Fatal("expected recurring event to be hidden after twelve hours from today's occurrence")
	}
}
