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

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await SecureStorageService.getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      final response = await ApiService.dio.get(
        '/profile',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  static Future<void> updateProfile({
    String? nome,
    String? cognome,
    String? email,
    String? password,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) throw Exception('No authentication token found');

    final Map<String, dynamic> body = {};
    if (nome != null && nome.isNotEmpty) body['nome'] = nome;
    if (cognome != null && cognome.isNotEmpty) body['cognome'] = cognome;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;

    try {
      final response = await ApiService.dio.post(
        '/profile/update',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
        throw Exception('Failed to update profile: $e');
    }
  }

  // ==== NUOVI METODI PER FORGOT PASSWORD ====

  /// Invia la mail con il codice a 4 cifre
  static Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Errore forgot password: $e');
      return false; // o rilancia l'errore per mostrare messaggi migliori in UI
    }
  }

  /// Verifica se il codice a 4 cifre è corretto
  static Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/verify-reset-code',
        data: {
          'email': email,
          'code': code,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Errore verify reset code: $e');
      throw Exception('Codice errato o scaduto');
    }
  }

  /// Imposta una nuova password fornendo l'email, il codice valido e la nuova pw
  static Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Errore reset password: $e');
      throw Exception('Impossibile resettare la password');
    }
  }
}
