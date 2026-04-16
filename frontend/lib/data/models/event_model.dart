class Event {
  final int id;
  final String titolo;
  final String descrizione;
  final String? immagineUrl;
  final DateTime dataEvento;
  final String oraEvento;
  final String? luogo;

  Event({
    required this.id,
    required this.titolo,
    required this.descrizione,
    this.immagineUrl,
    required this.dataEvento,
    required this.oraEvento,
    this.luogo,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      titolo: json['titolo'],
      descrizione: json['descrizione'],
      immagineUrl: json['immagine_url'],
      dataEvento: DateTime.parse(json['data_evento']),
      oraEvento: json['ora'],
      luogo: json['luogo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titolo': titolo,
      'descrizione': descrizione,
      'immagine_url': immagineUrl,
      'data_evento': dataEvento.toIso8601String(),
      'ora': oraEvento,
      'luogo': luogo,
    };
  }
}
