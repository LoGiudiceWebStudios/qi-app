import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Risolve automaticamente l'URL in base al dispositivo in uso
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1'; // iOS e altri
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
