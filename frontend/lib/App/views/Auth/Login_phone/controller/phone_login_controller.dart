import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:astro_tale/App/views/Auth/OTP/otpScreen.dart';
import 'package:astro_tale/services/API/APIservice.dart';

class PhoneLoginController {
  static const String apiBaseUrl = authBaseUrl;

  static Future<void> sendOtp({
    required BuildContext context,
    required String? phoneNumber,
    required VoidCallback onStart,
    required VoidCallback onStop,
  }) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _snack(context, "Please enter a valid phone number");
      return;
    }

    onStart();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerification(phoneNumber: phoneNumber),
          ),
        );
      } else {
        _snack(context, data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _snack(context, 'Error: $e');
    } finally {
      onStop();
    }
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
