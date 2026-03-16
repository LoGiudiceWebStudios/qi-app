# Usiamo l'immagine ufficiale di Go (versione corrispondente al tuo go.mod)
FROM golang:1.23.4-alpine

# Impostiamo la cartella di lavoro dentro il container
WORKDIR /app

# Installiamo git (spesso richiesto per scaricare alcune dipendenze Go)
RUN apk add --no-cache git

# Copiamo prima i file delle dipendenze per sfruttare la cache di Docker
COPY go.mod go.sum ./
RUN go mod download

# Copiamo il resto del codice sorgente
COPY . .

# Esponiamo la porta su cui gira Gin
EXPOSE 8080

# Avviamo il server
CMD ["go", "run", "cmd/api/main.go"]
