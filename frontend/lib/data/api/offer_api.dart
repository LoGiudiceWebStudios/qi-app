import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offer_model.dart';
import '../services/api_service.dart';

class OfferApi {
  Future<List<OfferModel>> fetchOffers() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/offers'))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Errore caricamento offerte: ${response.statusCode}');
      }

      final dynamic decoded = json.decode(response.body);

      List<dynamic> offersJson = [];
      if (decoded is List<dynamic>) {
        offersJson = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'];
        if (data is List<dynamic>) {
          offersJson = data;
        }
      }

      return offersJson
          .whereType<Map<String, dynamic>>()
          .map(OfferModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Errore di connessione al server: $e');
    }
  }

  Future<Map<String, dynamic>> generateOfferCode(String offerId) async {
    try {
      final response = await ApiService.dio.post('/offers/$offerId/generate');
      
      if (response.statusCode != 200) {
        throw Exception('Errore generazione codice offerta: ${response.data}');
      }

      final dynamic decoded = response.data;
      return decoded['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }
}
