package models

type HomeEvent struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	ImageUrl string `json:"imageUrl"`
	Date     string `json:"date"`
}

type HomeOffer struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	ImageUrl string `json:"imageUrl"`
}

type OfferAPI struct {
	ID          string  `json:"id"`
	ImageURL    string  `json:"imageUrl"`
	Title       string  `json:"title"`
	Description string  `json:"description"`
	TermsText   *string `json:"termsText,omitempty"`
	ActionText  string  `json:"actionText"`
	Code        string  `json:"code"`
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
}
