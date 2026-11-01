package offervisibility

import (
	"testing"
	"time"

	"qi-backend/internal/models"
)

func TestEvaluateUpcomingRecurringOffer(t *testing.T) {
	location := time.FixedZone("test", 0)
	now := time.Date(2026, time.October, 27, 16, 0, 0, 0, location)
	offer := models.Offer{
		ValidaDal:        time.Date(2026, time.October, 1, 0, 0, 0, 0, location),
		ValidaFino:       time.Date(2026, time.December, 31, 0, 0, 0, 0, location),
		OraValidaDal:     "18:00",
		OraValidaFino:    "22:00",
		RicorrenzaGiorno: int(time.Tuesday),
	}

	status := Evaluate(offer, now)
	if !status.Visible || status.Active {
		t.Fatalf("expected visible but inactive offer, got %+v", status)
	}
	if status.ActivationLabel != "Oggi dalle 18:00" {
		t.Fatalf("unexpected activation label: %q", status.ActivationLabel)
	}
}

func TestEvaluateOfferAfterValidityEndIsHidden(t *testing.T) {
	location := time.FixedZone("test", 0)
	now := time.Date(2026, time.October, 27, 12, 0, 0, 0, location)
	offer := models.Offer{
		ValidaDal:        time.Date(2026, time.October, 1, 0, 0, 0, 0, location),
		ValidaFino:       time.Date(2026, time.October, 26, 0, 0, 0, 0, location),
		RicorrenzaGiorno: int(time.Tuesday),
	}

	status := Evaluate(offer, now)
	if status.Visible {
		t.Fatalf("expected expired offer to be hidden, got %+v", status)
	}
}

func TestEvaluateFutureStartDate(t *testing.T) {
	location := time.FixedZone("test", 0)
	now := time.Date(2026, time.October, 27, 12, 0, 0, 0, location)
	offer := models.Offer{
		ValidaDal:        time.Date(2026, time.October, 29, 0, 0, 0, 0, location),
		ValidaFino:       time.Date(2026, time.November, 30, 0, 0, 0, 0, location),
		OraValidaDal:     "18:00",
		OraValidaFino:    "22:00",
		RicorrenzaGiorno: -1,
	}

	status := Evaluate(offer, now)
	if !status.Visible || status.Active {
		t.Fatalf("expected visible but inactive future offer, got %+v", status)
	}
	if status.ActivationLabel != "Dal 29/10 dalle 18:00" {
		t.Fatalf("unexpected activation label: %q", status.ActivationLabel)
	}
}
