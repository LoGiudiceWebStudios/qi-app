import sys
with open('C:/Users/Utente/Documents/Progetti/Qi_App/qi-app/backend/internal/handlers/auth.go', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('user, err := h.authService.GetProfile(userID.(uint))', 'var uid uint\n\tswitch v := userID.(type) {\n\tcase float64:\n\t\tuid = uint(v)\n\tcase uint:\n\t\tuid = v\n\t}\n\tuser, err := h.authService.GetProfile(uid)')
content = content.replace('if err := h.authService.UpdateProfile(userID.(uint), req.Nome, req.Cognome, req.Email, req.Password); err != nil {', 'var uid uint\n\tswitch v := userID.(type) {\n\tcase float64:\n\t\tuid = uint(v)\n\tcase uint:\n\t\tuid = v\n\t}\n\tif err := h.authService.UpdateProfile(uid, req.Nome, req.Cognome, req.Email, req.Password); err != nil {')
with open('C:/Users/Utente/Documents/Progetti/Qi_App/qi-app/backend/internal/handlers/auth.go', 'w', encoding='utf-8') as f:
    f.write(content)
