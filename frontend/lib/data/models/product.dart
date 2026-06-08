class Product {
  final int id;
  final int categoryId;
  final String name;
  final String shortDesc;
  final String description;
  final double price;
  final String imageUrl;
  final String? model3dUrl;
  final bool isAvailable;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.shortDesc,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.model3dUrl,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      shortDesc: json['short_desc'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      model3dUrl: json['model3d_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}
