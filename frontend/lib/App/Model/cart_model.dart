class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'],
      userId: json['user'] is Map ? json['user']['_id'] : json['user'],
      items: (json['items'] as List? ?? [])
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /* =========================
     CART TOTAL CALCULATIONS
     ========================= */

  /// Sum of (price × quantity) for all items
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Static discount (can be dynamic later)
  double get discount {
    return items.isEmpty ? 0.0 : 50.0;
  }

  /// Final payable amount
  double get total {
    final value = subtotal - discount;
    return value < 0 ? 0.0 : value;
  }
}

class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    if (product == null) {
      return CartItemModel(
        productId: json['product'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        image: json['image'] ?? '',
        quantity: json['quantity'] ?? 1,
      );
    }

    return CartItemModel(
      productId: product['_id'] ?? '',
      name: product['name'] ?? '',
      price: (product['price'] as num?)?.toDouble() ?? 0,
      image: product['images'] != null && product['images'].isNotEmpty
          ? product['images'][0]
          : '',
      quantity: json['quantity'] ?? 1,
    );
  }
}
