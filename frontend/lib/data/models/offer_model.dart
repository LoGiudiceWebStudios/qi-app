class OfferModel {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String? termsText;
  final String actionText;
  final String code;

  const OfferModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.termsText,
    required this.actionText,
    required this.code,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: (json['id'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      termsText: json['termsText']?.toString(),
      actionText: (json['actionText'] ?? 'Get Code').toString(),
      code: (json['code'] ?? '').toString(),
    );
  }
}
