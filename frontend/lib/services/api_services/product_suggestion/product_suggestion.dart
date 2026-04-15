import "dart:convert";

import "package:astro_tale/App/Model/suggestion_model.dart";
import "package:astro_tale/services/API/APIservice.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

class ProductSuggestionService {
  final String apiUrl = "$baseurl/user/home-products";

  Future<List<ProductSuggestion>> fetchSuggestions() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        debugPrint("Suggestions API failed: ${response.statusCode}");
        return <ProductSuggestion>[];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = (data["products"] as List<dynamic>? ?? <dynamic>[]);
      return products
          .map(
            (dynamic json) =>
                ProductSuggestion.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
      return <ProductSuggestion>[];
    }
  }
}
