import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/home_data.dart';

class HomeApi {
  Future<HomeData> fetchHomeData() async {
    try {
      final response = await ApiService.dio.get('/home');
      final responseData = response.data['data'] ?? response.data;
      return HomeData.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
