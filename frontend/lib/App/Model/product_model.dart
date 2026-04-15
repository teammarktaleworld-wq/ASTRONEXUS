enum AstrologyType { gemstone, pooja, report, consultation }

enum DeliveryType { physical, digital }

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;

  /// Category can be:
  /// - String (ObjectId)
  /// - Map (if backend uses populate)
  final dynamic category;

  final List<String> images;
  final AstrologyType astrologyType;
  final int stock;
  final DeliveryType deliveryType;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    required this.images,
    required this.astrologyType,
    required this.stock,
    required this.deliveryType,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'], // nullable
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: category != null
          ? category
          : null, // keep null if category missing
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      astrologyType: _parseAstrologyType(json['astrologyType']),
      stock: json['stock'] ?? 0,
      deliveryType: _parseDeliveryType(json['deliveryType']),
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Useful for Add / Update product (Admin)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category is Map ? category['_id'] : category,
      'images': images,
      'astrologyType': astrologyType.name,
      'stock': stock,
      'deliveryType': deliveryType.name,
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }

  // ================== HELPERS ==================

  static AstrologyType _parseAstrologyType(String? value) {
    switch (value) {
      case 'pooja':
        return AstrologyType.pooja;
      case 'report':
        return AstrologyType.report;
      case 'consultation':
        return AstrologyType.consultation;
      case 'gemstone':
      default:
        return AstrologyType.gemstone;
    }
  }

  static DeliveryType _parseDeliveryType(String? value) {
    switch (value) {
      case 'digital':
        return DeliveryType.digital;
      case 'physical':
      default:
        return DeliveryType.physical;
    }
  }
}
