class PaymentModel {
  final String id;
  final String userId;
  final String? orderId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'],
      userId: json['user'],
      orderId: json['order'],
      amount: (json['amount'] as num).toDouble(),
      method: json['method'],
      status: json['status'],
      transactionId: json['transactionId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
