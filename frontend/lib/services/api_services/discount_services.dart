import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../App/Model/place/discount_model.dart';
import '../API/APIservice.dart';

class DiscountService {
  /// Get all available discounts
  static Future<List<Discount>> getDiscounts() async {
    final res = await http.get(Uri.parse("$baseurl/api/discount"));

    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      return data.map((e) => Discount.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load discounts");
    }
  }

  /// Get discount by code
  static Future<Discount> getDiscountByCode(String code) async {
    final res = await http.get(Uri.parse("$baseurl/api/discount/$code"));

    if (res.statusCode == 200) {
      return Discount.fromJson(json.decode(res.body) as Map<String, dynamic>);
    } else {
      throw Exception("Invalid or expired discount");
    }
  }

  /// Apply discount to cart amount
  static Future<Map<String, dynamic>> applyDiscount({
    required String code,
    required double amount,
  }) async {
    final res = await http.post(
      Uri.parse("$baseurl/api/discount/apply"),
      headers: const {"Content-Type": "application/json"},
      body: json.encode({"code": code, "amount": amount}),
    );

    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to apply discount");
    }
  }
}
