import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../services/api_service.dart';

class EventApi {
  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/events')).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> eventsJson = data['data'];

        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Errore caricamento eventi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore di connessione al server: $e');
    }
  }
}
