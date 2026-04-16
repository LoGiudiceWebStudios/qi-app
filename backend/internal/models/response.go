package models

// StandardResponse standardizza il formato JSON in uscita dalle API
type StandardResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// SuccessResponse helper per costruire una risposta di successo
func SuccessResponse(message string, data interface{}) StandardResponse {
	return StandardResponse{
		Success: true,
		Message: message,
		Data:    data,
	}
}

// ErrorResponse helper per costruire una risposta di errore
func ErrorResponse(message string, err string) StandardResponse {
	return StandardResponse{
		Success: false,
		Message: message,
		Error:   err,
	}
}
