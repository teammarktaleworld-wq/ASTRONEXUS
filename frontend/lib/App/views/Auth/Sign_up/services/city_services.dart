import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../Model/place/place_suggestion.dart';

class PlaceApiService {
  static Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) {
      return const <PlaceSuggestion>[];
    }

    final url = Uri.parse("https://nominatim.openstreetmap.org/search").replace(
      queryParameters: <String, String>{
        "q": cleaned,
        "format": "json",
        "limit": "5",
        "addressdetails": "1",
      },
    );

    final res = await http.get(
      url,
      headers: const <String, String>{"User-Agent": "astro-nexus-app"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is! List) {
        return const <PlaceSuggestion>[];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .where(_isCityLike)
          .map(PlaceSuggestion.fromNominatim)
          .where((p) => p.name.trim().isNotEmpty)
          .toList(growable: false);
    }

    return const <PlaceSuggestion>[];
  }

  static bool _isCityLike(Map<String, dynamic> item) {
    final type = (item["type"] ?? "").toString().toLowerCase();
    final addresstype = (item["addresstype"] ?? "").toString().toLowerCase();
    const cityLike = <String>{
      "city",
      "town",
      "village",
      "municipality",
      "hamlet",
    };
    if (cityLike.contains(type) || cityLike.contains(addresstype)) {
      return true;
    }

    final address = item["address"];
    if (address is! Map) {
      return false;
    }
    return address["city"] != null ||
        address["town"] != null ||
        address["village"] != null ||
        address["municipality"] != null;
  }
}
