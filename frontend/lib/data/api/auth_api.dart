import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

class AuthApi {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'];
        await SecureStorageService.saveToken(token);
        return response.data;
      } else {
         throw Exception(response.data['message'] ?? 'Errore durante il login');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Errore di autenticazione');
      }
      throw Exception('Errore di connessione al server');
    }
  }

  Future<Map<String, dynamic>> signUp(String nome, String cognome, String telefono, String email, String password) async {
    try {
      final response = await ApiService.dio.post('/auth/signup', data: {
        'nome': nome,
        'cognome': cognome,
        'telefono': telefono,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
         final token = response.data['token'];
         await SecureStorageService.saveToken(token);
         return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Errore durante la registrazione');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Errore durante la registrazione');
      }
      throw Exception('Errore di connessione al server');
    }
  }

  Future<void> logout() async {
    await SecureStorageService.deleteToken();
  }
}
