import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthApi {
  // Metodo per il login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data; // Ritorna token ed utente
      } else {
        throw Exception(data['message'] ?? 'Errore durante il login');
      }
    } catch (e) {
      throw Exception('Errore di connessione: $e');
    }
  }

  // Metodo per Registrazione
  Future<Map<String, dynamic>> signUp(
      String nome, String cognome, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'cognome': cognome,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Errore durante la registrazione');
      }
    } catch (e) {
      throw Exception('Errore di connessione: $e');
    }
  }
}
