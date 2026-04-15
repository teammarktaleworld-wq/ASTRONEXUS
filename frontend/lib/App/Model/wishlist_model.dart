class WishlistModel {
  final String userId;
  final List<Product> products;

  WishlistModel({required this.userId, required this.products});

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      userId: json['userId'] ?? '',
      products: (json['products'] as List<dynamic>? ?? [])
          .map((p) => Product.fromJson(p))
          .toList(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final List<String> images;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
