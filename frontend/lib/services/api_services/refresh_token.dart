// services/API/APIservice.dart
import 'dart:convert';
import 'package:astro_tale/services/API/APIservice.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class APIService {
  /// Refresh JWT using refresh token
  static Future<String?> refreshToken(String refreshToken) async {
    final url = Uri.parse('$baseurl/user/refresh-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return data['token'];
      }
    }
    debugPrint('Token refresh failed: ${response.statusCode}');

    return null; // failed
  }
}
