class Discount {
  final String code;
  final int percentage;
  final DateTime expiry;

  Discount({
    required this.code,
    required this.percentage,
    required this.expiry,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      code: json['code'],
      percentage: json['percentage'],
      expiry: DateTime.parse(json['expiry']),
    );
  }
}
