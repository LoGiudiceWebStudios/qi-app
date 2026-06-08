import 'package:dio/dio.dart';
import '../services/api_service.dart';

class PointsApi {
  Future<Map<String, dynamic>> claimPoints(String code) async {
    try {
      final response = await ApiService.dio.post(
        '/points/claim',
        data: {'code': code},
      );
      
      // Ritorniamo i dati (es. total_points, points_awarded)
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Errore durante la raccolta punti');
      }
      throw Exception(e.message ?? 'Errore di connessione');
    }
  }
}
