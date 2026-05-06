import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Risolve automaticamente l'URL in base al dispositivo in uso
  static String get serverUrl {
    // Prova a usare 10.0.2.2 per l'emulatore Android, altrimenti localhost
    if (kIsWeb) return 'http://localhost:9090';
    if (Platform.isAndroid) return 'http://10.0.2.2:9090';
    // Se stai usando un dispositivo fisico, potresti dover usare il tuo indirizzo IP locale, ad es: 'http://192.168.1.X:9090'
    return 'http://localhost:9090'; // iOS e altri
  }

  static String get baseUrl {
    return '$serverUrl/api/v1';
  }

  // Chiamata di test al nostro endpoint Go
  Future<String> pingBackend() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ping'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message']; // "Il Backend di QI App è operativo!"
      } else {
        return 'Errore Server: ${response.statusCode}';
      }
    } catch (e) {
      return 'Errore di connessione: Verifica che il backend sia acceso. Dettagli: $e';
    }
  }
}
