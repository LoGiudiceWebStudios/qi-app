package admin

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type DashboardHandler struct {
}

func NewDashboardHandler() *DashboardHandler {
	return &DashboardHandler{}
}

func (h *DashboardHandler) RenderDashboard(c *gin.Context) {
	// Qui poi interroghiamo GORM per ottenere conteggi di eventi, utenti, etc.
	// Per ora facciamo un pass mock
	data := gin.H{
		"Title":       "Dashboard Qi App",
		"TotalEvents": 14,
		"TotalOffers": 5,
	}

	c.HTML(http.StatusOK, "dashboard.html", data)
}
