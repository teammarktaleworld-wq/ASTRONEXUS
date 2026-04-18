import "dart:convert";

import "package:astro_tale/services/API/APIservice.dart";
import "package:astro_tale/services/api_services/api_service.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

class FeedbackApi {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getProductFeedback(String productId) async {
    final response = await http.get(
      Uri.parse("$baseurl/api/feedback/$productId"),
      headers: const <String, String>{"Content-Type": "application/json"},
    );

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to load feedback");
    }

    return (data["feedbacks"] as List<dynamic>? ?? <dynamic>[]);
  }

  Future<void> submitFeedback({
    required String productId,
    required double rating,
    required String review,
  }) async {
    final token = await _api.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("User token missing. Please login again.");
    }

    final response = await http.post(
      Uri.parse("$baseurl/api/feedback"),
      headers: <String, String>{
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(<String, dynamic>{
        "productId": productId,
        "rating": rating,
        "description": review,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201 || data["success"] != true) {
      debugPrint(
        "Submit feedback failed: ${response.statusCode} ${response.body}",
      );
      throw Exception(data["message"] ?? "Failed to submit review");
    }
  }
}
