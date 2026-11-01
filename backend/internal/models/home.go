package models

type HomeEvent struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	ImageUrl string `json:"imageUrl"`
	Date     string `json:"date"`
}

type HomeOffer struct {
	ID              string `json:"id"`
	Title           string `json:"title"`
	ImageUrl        string `json:"imageUrl"`
	IsActive        bool   `json:"isActive"`
	ActivationLabel string `json:"activationLabel,omitempty"`
}

type HomePost struct {
	ID        string `json:"id"`
	Title     string `json:"title"`
	Message   string `json:"message"`
	CreatedAt string `json:"createdAt"`
}

type OfferAPI struct {
	ID              string  `json:"id"`
	ImageURL        string  `json:"imageUrl"`
	Title           string  `json:"title"`
	Description     string  `json:"description"`
	TermsText       *string `json:"termsText,omitempty"`
	ActionText      string  `json:"actionText"`
	Code            string  `json:"code"`
	IsActive        bool    `json:"isActive"`
	ActivationLabel string  `json:"activationLabel,omitempty"`
}

type HomeData struct {
	IsOpen             bool        `json:"isOpen"`
	OpeningTime        string      `json:"openingTime"`
	ClosingTime        string      `json:"closingTime"`
	IsKitchenOpen      bool        `json:"isKitchenOpen"`
	KitchenOpeningTime string      `json:"kitchenOpeningTime"`
	KitchenClosingTime string      `json:"kitchenClosingTime"`
	LocationName       string      `json:"locationName"`
	NextEvent          string      `json:"nextEvent"`
	Events             []HomeEvent `json:"events"`
	Offers             []HomeOffer `json:"offers"`
	Posts              []HomePost  `json:"posts"`
}
