import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:astro_tale/services/API/APIservice.dart';
import 'package:http/http.dart' as http;

class LoginApi {
  static Future<Map<String, dynamic>> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse("$baseurl/user/login/phone");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"phone": phone, "password": password}),
          )
          .timeout(const Duration(seconds: 30)); // ⬅️ increased timeout

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data;
      } else {
        throw Exception(
          data["message"] ?? data["error"] ?? "Invalid phone or password",
        );
      }
    }
    // ⏰ Server too slow
    on TimeoutException {
      throw Exception("Server is busy. Please try again shortly.");
    }
    // 📡 No internet
    on SocketException {
      throw Exception("No internet connection.");
    }
    // ❓ Any other error
    catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Login failed. Please try again.");
    }
  }
}
