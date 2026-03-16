# QI App Monorepo


# Database

docker compose up -d db

# Backend

cd backend/
go mod tidy
go run cmd/api/main.go

verifica: curl http://localhost:8080/api/v1/ping

# Frontend

cd frontend/
flutter pub get
flutter run
