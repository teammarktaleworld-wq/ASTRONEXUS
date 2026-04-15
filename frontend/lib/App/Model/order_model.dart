import 'package:astro_tale/App/Model/payment_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final String deliveryType;
  final PaymentModel? payment; // ✅ FIXED
  final String? astrologyReportLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryType,
    this.payment,
    this.astrologyReportLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'Placed',
      deliveryType: json['deliveryType'] ?? '',
      payment: json['paymentId'] != null && json['paymentId'] is Map
          ? PaymentModel.fromJson(json['paymentId'])
          : null,
      astrologyReportLink: json['astrologyReportLink'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class OrderItemModel {
  final String productId;
  final int quantity;
  final double price;
  final ProductModel? product; // Added populated product

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product'] is Map
          ? json['product']['_id']
          : json['product'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      product: json['product'] != null && json['product'] is Map
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'] ?? "Unknown Product",
      price: (json['price'] as num).toDouble(),
      images: (json['images'] as List).map((e) => e.toString()).toList(),
    );
  }
}
