import 'dart:convert';
import 'package:astro_tale/App/Model/tarot_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../API/APIservice.dart';

class TarotApi {
  static Future<List<TarotCard>> fetchCards(int count) async {
    final n = count.clamp(1, 78);
    final url = Uri.parse('$baseurl/api/tarot/random?n=$n');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final res = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      final body = res.body;
      throw Exception('Tarot API failed (${res.statusCode}): $body');
    }

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    final rootCards = decoded['cards'];
    final nestedCards = (decoded['data'] as Map<String, dynamic>?)?['cards'];
    final cardsRaw = rootCards ?? nestedCards;

    if (cardsRaw is! List) {
      throw Exception('Tarot API response missing cards');
    }

    return cardsRaw
        .map((e) => TarotCard.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }
}
