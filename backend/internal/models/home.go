package models

// Queste struct serviranno per definire la risposta della home page

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

type HomeData struct {
	IsOpen       bool        `json:"isOpen"`
	ClosingTime  string      `json:"closingTime"`
	LocationName string      `json:"locationName"`
	NextEvent    string      `json:"nextEvent"`
	Events       []HomeEvent `json:"events"`
	Offers       []HomeOffer `json:"offers"`
}
