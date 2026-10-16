package admin

import (
	"html/template"
	"testing"
)

func TestAdminTemplatesParse(t *testing.T) {
	if _, err := template.ParseGlob("../../templates/admin/*.html"); err != nil {
		t.Fatalf("failed to parse admin templates: %v", err)
	}
}
