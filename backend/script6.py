import sys
with open('C:/Users/Utente/Documents/Progetti/Qi_App/qi-app/frontend/lib/presentation/pages/scan_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('if (response.data[''success''] == true) {', 'if (response.data != null) {')
content = content.replace('_userPoints = response.data[''data''][''punti''];\n          _userId = response.data[''data''][''id''];\n          _userName = response.data[''data''][''nome''];', 'final data = response.data[''data''] ?? response.data;\n          _userPoints = data[''punti''];\n          _userId = data[''id''];\n          _userName = data[''nome''];')
with open('C:/Users/Utente/Documents/Progetti/Qi_App/qi-app/frontend/lib/presentation/pages/scan_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)
