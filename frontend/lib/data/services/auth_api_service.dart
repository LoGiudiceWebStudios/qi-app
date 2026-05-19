import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class AuthApiService {

  static Future<String?> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Errore nel recupero del token FCM: $e');
      return null;
    }
  }
  
  /// Registrazione - Crea un account ed effettua l'accesso automatico
  static Future<bool> signUp({
    required String nome,
    required String email,
    required String password,
    String? cognome,
    String? telefono,
  }) async {
    try {
      String? fcmToken = await _getFcmToken();
      final response = await ApiService.dio.post(
        '/auth/signup',
        data: {
          'nome': nome,
          'email': email,
          'password': password,
          if (cognome != null) 'cognome': cognome,
          if (telefono != null) 'telefono': telefono,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      // Status 201 Created previsto dal tuo backend
      if (response.statusCode == 201 && response.data['success'] == true) {
        final token = response.data['token'];
        
        if (token != null) {
          // Archiviazione sicura nel Keystore/Keychain
          await SecureStorageService.saveToken(token);
          return true;
        }
      }
      return false;
      
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Errore dal server durante la registrazione');
      } else {
        throw Exception('Nessuna risposta dal server. Verifica la connessione.');
      }
    }
  }

  /// Accesso standard
  static Future<bool> login(String email, String password) async {
    try {
      String? fcmToken = await _getFcmToken();
      final response = await ApiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'];
        if (token != null) {
          // Archiviazione sicura del token JWT
          await SecureStorageService.saveToken(token);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Credenziali non valide');
      } else {
        throw Exception('Errore di connessione al server');
      }
    }
  }

  /// Logout - Termina la sessione eliminando il token JWT sicuro
  static Future<void> logout() async {
    await SecureStorageService.deleteToken();
  }

  /// Login o Registrazione tramite Provider (Google, Apple)
  static Future<bool> socialLogin({
    required String provider,
    required String socialId,
    required String email,
    required String name,
    String? idToken,
  }) async {
    try {
      String? fcmToken = await _getFcmToken();
      final response = await ApiService.dio.post(
        '/auth/social',
        data: {
          'provider': provider,
          'social_id': socialId,
          'id_token': idToken,
          'email': email,
          'nome': name, // il backend estrarrà il campo "nome"
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'];
        if (token != null) {
          await SecureStorageService.saveToken(token);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Errore di autenticazione social');
      } else {
        throw Exception('Nessuna risposta dal server');
      }
    }
  }
}
