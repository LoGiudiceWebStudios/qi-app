1. Backend (Go - ad es. con Gin o Echo)
Autenticazione e Autorizzazione: Non lasciare mai rotte sensibili pubbliche. Useremo sempre middleware per verificare JWT (JSON Web Tokens) o sessioni valide prima di permettere l'accesso ai dati (es. proteggendo le rotte sotto un gruppo /api/v1/private).

Validazione degli Input: Non fidarsi mai dei dati inviati da Flutter. Controllare sempre i payload (es. c.ShouldBindJSON in Gin) per evitare SQL Injection o comportamenti inattesi.

CORS (Cross-Origin Resource Sharing): Configurare regole rigide per accettare richieste solo dall'origine della tua app web (se applicabile) e non da *.

Gestione degli Errori: Non restituire mai stack trace dettagliati al frontend, per evitare di esporre la struttura interna del database o del codice.

2. Frontend (Flutter)
Archiviazione Sicura: Mai salvare token o password in SharedPreferences in chiaro. Bisogna usare pacchetti come flutter_secure_storage che sfruttano le KeyChain/Keystore native di iOS e Android.

Protezione delle Rotte (GoRouter / Navigator 2.0): Implementare "guardie" che reindirizzino gli utenti non autenticati alla schermata di login se cercano di accedere a schermate protette.

Comunicazione: Usare esclusivamente HTTPS per comunicare con il backend in Go, anche durante i test se possibile (evitando il traffico in chiaro).