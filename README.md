## QI Food&Focus Mobile App 

# Accesso DB: 
	localhost:5432
	User: admin
	Password: admin
	Accesso pgAdmin: http://localhost:5050

# Avvio Rapido Infrastruttura
Esegui `docker-compose up -d` dalla root per avviare il database.

# Avvio Backend 

cd backend
go mod tidy
go run cmd/api/main.go

#Avvio Frontend

cd frontend
flutter pub get
flutter run 
