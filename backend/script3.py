import sys
with open('C:/Users/Utente/Documents/Progetti/Qi_App/qi-app/backend/internal/database/db.go', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('&models.Setting{},', '&models.Setting{},\n\t\t&models.PointsQRCode{},\n\t\t&models.PointsTransaction{},\n\t\t&models.Reward{},')
with open('C:/Users/Utente/Documents/Progetti/Qi_App/qi-app/backend/internal/database/db.go', 'w', encoding='utf-8') as f:
    f.write(content)
