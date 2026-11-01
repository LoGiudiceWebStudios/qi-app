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

func TestRecurringEventIsAlwaysVisibleAndAdvancesDateAfter12Hours(t *testing.T) {
	location := eventLocation
	// 16 October 2026 is a Friday (Weekday == 5)
	fridayNoon := time.Date(2026, time.October, 16, 12, 0, 0, 0, location)
	event := models.Event{
		DataEvento:       time.Date(2026, time.January, 1, 0, 0, 0, 0, time.UTC),
		Ora:              "09:00",
		RicorrenzaGiorno: int(time.Friday),
		CreatedAt:        fridayNoon.Add(-24 * time.Hour),
	}

	if !IsActive(event, fridayNoon) {
		t.Fatal("expected recurring event to be active")
	}
	if got := EffectiveDate(event, fridayNoon).Format("2006-01-02"); got != "2026-10-16" {
		t.Fatalf("EffectiveDate() within 12h = %s, want 2026-10-16", got)
	}

	// After 12 hours from Friday 09:00 -> Friday 21:01, date should roll to next Friday (2026-10-23)
	afterWindow := time.Date(2026, time.October, 16, 21, 1, 0, 0, location)
	if !IsActive(event, afterWindow) {
		t.Fatal("expected recurring event to stay active for the next week")
	}
	if got := EffectiveDate(event, afterWindow).Format("2006-01-02"); got != "2026-10-23" {
		t.Fatalf("EffectiveDate() after 12h = %s, want 2026-10-23", got)
	}
}
