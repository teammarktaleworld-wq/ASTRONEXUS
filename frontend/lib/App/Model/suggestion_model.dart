// models/product_suggestion.dart
class ProductSuggestion {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> images;
  final String astrologyType;
  final int stock;
  final String deliveryType;
  final bool isActive;
  final bool isDeleted;
  final bool showInHome;
  final int homePriority;
  final DateTime? lastShownAt;

  ProductSuggestion({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.images,
    required this.astrologyType,
    required this.stock,
    required this.deliveryType,
    required this.isActive,
    required this.isDeleted,
    required this.showInHome,
    required this.homePriority,
    this.lastShownAt,
  });

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      categoryId: json['category'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => img.toString())
              .toList() ??
          [],
      astrologyType: json['astrologyType'] ?? 'gemstone',
      stock: json['stock'] ?? 0,
      deliveryType: json['deliveryType'] ?? 'physical',
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      showInHome: json['showInHome'] ?? false,
      homePriority: json['homePriority'] ?? 0,
      lastShownAt: json['lastShownAt'] != null
          ? DateTime.parse(json['lastShownAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'price': price,
    'category': categoryId,
    'images': images,
    'astrologyType': astrologyType,
    'stock': stock,
    'deliveryType': deliveryType,
    'isActive': isActive,
    'isDeleted': isDeleted,
    'showInHome': showInHome,
    'homePriority': homePriority,
    'lastShownAt': lastShownAt?.toIso8601String(),
  };
}
