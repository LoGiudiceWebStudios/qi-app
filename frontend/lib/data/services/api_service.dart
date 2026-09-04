import 'package:dio/dio.dart';
import 'secure_storage_service.dart';
import '../../core/services/app_navigator.dart';

class ApiService {
  static String get serverUrl {
    return 'https://app.qifoodfocus.it'; // Se hai un reverse proxy (es. Nginx) HTTPS => 9090
    //eturn 'http://192.168.1.115:9090'; // Per sviluppo locale, assicurati di usare l'IP corretto se stai usando un emulatore
  }

  static String get baseUrl {
    return '$serverUrl/api/v1';
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await SecureStorageService.deleteToken();
            appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
          }
           return handler.next(error); 
        }
      ),
    );
}

