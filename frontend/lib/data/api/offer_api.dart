import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../models/offer_model.dart';
import '../services/api_service.dart';

class OfferApi {
  // Esempio per quando integrerai le offerte dal backend:
  /*
  Future<List<Offer>> fetchOffers() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/offers'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> offersJson = data['data'];

        return offersJson.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Errore caricamento offerte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore di connessione al server: $e');
    }
  }
  */
}
