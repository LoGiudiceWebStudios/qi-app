import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

class ApiService {
  static String get serverUrl {
    //return 'https://app.qifoodfocus.it'; // Se hai un reverse proxy (es. Nginx) HTTPS => 9090
    return 'http://192.168.1.127:9090'; // Per sviluppo locale, assicurati di usare l'IP corretto se stai usando un emulatore
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
        onError: (error, handler) {
           return handler.next(error); 
        }
      ),
    );
}

