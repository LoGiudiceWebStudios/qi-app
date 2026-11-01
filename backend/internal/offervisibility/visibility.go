package offervisibility

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"qi-backend/internal/models"
)

type Status struct {
	Visible          bool
	Active           bool
	ActivationLabel  string
	NextActivationAt time.Time
}

var italianWeekdays = [...]string{"domenica", "lunedì", "martedì", "mercoledì", "giovedì", "venerdì", "sabato"}

func Evaluate(offer models.Offer, now time.Time) Status {
	location := now.Location()
	today := dateOnly(now, location)
	startsOn := dateOnly(offer.ValidaDal, location)
	endsOn := dateOnly(offer.ValidaFino, location)
	status := Status{Visible: !today.After(endsOn)}
	if !status.Visible {
		return status
	}

	startMinutes, endMinutes, hasWindow := timeWindow(offer)
	dateIsValid := !today.Before(startsOn) && !today.After(endsOn)
	weekdayMatches := offer.RicorrenzaGiorno < 0 || offer.RicorrenzaGiorno > 6 || int(now.Weekday()) == offer.RicorrenzaGiorno
	timeIsValid := !hasWindow || inTimeWindow(now.Hour()*60+now.Minute(), startMinutes, endMinutes)
	status.Active = dateIsValid && weekdayMatches && timeIsValid
	if status.Active {
		return status
	}

	candidateStart := today
	if startsOn.After(today) {
		candidateStart = startsOn
	}
	for offset := 0; offset <= 14; offset++ {
		candidateDay := candidateStart.AddDate(0, 0, offset)
		if candidateDay.After(endsOn) {
			break
		}
		if offer.RicorrenzaGiorno >= 0 && offer.RicorrenzaGiorno <= 6 && int(candidateDay.Weekday()) != offer.RicorrenzaGiorno {
			continue
		}

		activation := candidateDay
		if hasWindow {
			activation = candidateDay.Add(time.Duration(startMinutes) * time.Minute)
		}
		if candidateDay.Equal(today) && hasWindow && now.After(candidateDay.Add(time.Duration(endMinutes)*time.Minute)) && startMinutes <= endMinutes {
			continue
		}
		if candidateDay.Equal(today) && hasWindow && startMinutes > endMinutes && now.Hour()*60+now.Minute() > endMinutes && now.Hour()*60+now.Minute() < startMinutes {
			continue
		}
		if activation.Before(now) {
			continue
		}

		status.NextActivationAt = activation
		status.ActivationLabel = activationLabel(offer, activation, today, startsOn, startMinutes, hasWindow)
		return status
	}

	status.Visible = false
	return status
}

func dateOnly(value time.Time, location *time.Location) time.Time {
	return time.Date(value.Year(), value.Month(), value.Day(), 0, 0, 0, 0, location)
}

func timeWindow(offer models.Offer) (int, int, bool) {
	startValue := strings.TrimSpace(offer.OraValidaDal)
	endValue := strings.TrimSpace(offer.OraValidaFino)
	if startValue == "" || endValue == "" {
		return 0, 0, false
	}
	start, startErr := time.Parse("15:04", startValue)
	end, endErr := time.Parse("15:04", endValue)
	if startErr != nil || endErr != nil {
		return 0, 0, false
	}
	return start.Hour()*60 + start.Minute(), end.Hour()*60 + end.Minute(), true
}

func inTimeWindow(current, start, end int) bool {
	if start == end {
		return true
	}
	if start < end {
		return current >= start && current <= end
	}
	return current >= start || current <= end
}

func activationLabel(offer models.Offer, activation, today, startsOn time.Time, startMinutes int, hasWindow bool) string {
	activationTime := ""
	if hasWindow {
		activationTime = fmt.Sprintf(" dalle %02d:%02d", startMinutes/60, startMinutes%60)
	}
	activationDay := dateOnly(activation, today.Location())
	if activationDay.Equal(today) {
		return "Oggi" + activationTime
	}
	if offer.RicorrenzaGiorno >= 0 && offer.RicorrenzaGiorno <= 6 {
		return "Ogni " + italianWeekdays[offer.RicorrenzaGiorno] + activationTime
	}
	if activationDay.Equal(startsOn) && startsOn.After(today) {
		return "Dal " + startsOn.Format("02/01") + activationTime
	}
	if activationDay.Sub(today).Hours() < 48 {
		return "Domani" + activationTime
	}
	return "Il " + activationDay.Format("02/01") + activationTime
}

func ParseWeekday(value string) int {
	weekday, err := strconv.Atoi(value)
	if err != nil || weekday < 0 || weekday > 6 {
		return -1
	}
	return weekday
}
