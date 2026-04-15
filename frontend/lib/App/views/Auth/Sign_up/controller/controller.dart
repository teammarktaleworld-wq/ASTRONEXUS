import 'dart:convert';

import 'package:astro_tale/App/Model/Horoscope/horoscope_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../helper/Astrology_flow_helper.dart';
import '../../../../../helper/zodiac_helper.dart';
import '../../../../../services/API/APIservice.dart';
import '../../../../../services/api_services/chatbot/profile_services.dart';
import '../model/SignUp_Data_Model.dart';

class SignupController {
  final AstrologySignupModel model = AstrologySignupModel();

  // ------------------ SETTERS ------------------
  void setName(String name) => model.name = name.trim();
  void setEmail(String email) => model.email = email.trim();
  void setPhone(String phone) => model.phone = phone.trim();
  void setPassword(String password) => model.password = password;
  void setConfirmPassword(String confirmPassword) =>
      model.confirmPassword = confirmPassword;
  void setDateOfBirth(String date) => model.dateOfBirth = date;
  void setBirthTime(int hour, int minute, bool isAM) {
    model.hour = hour;
    model.minute = minute;
    model.isAM = isAM;
  }

  void setPlace(String place) => model.place = place.trim();

  // ------------------ SUBMIT SIGNUP ------------------
  Future<Map<String, dynamic>> submitSignup() async {
    final payload = model.toJson();
    final phone = payload['phone']?.toString() ?? '';

    if (model.name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (model.email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    if (phone.length < 10) {
      throw Exception('Enter a valid 10-digit phone number');
    }
    if (model.password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (model.password != model.confirmPassword) {
      throw Exception('Passwords do not match');
    }
    if (model.dateOfBirth.trim().isEmpty || model.place.trim().isEmpty) {
      throw Exception('Birth details are required');
    }

    DateTime dob;
    try {
      dob = DateTime.parse(model.dateOfBirth);
    } catch (_) {
      throw Exception('Select a valid date of birth');
    }

    String zodiacFromChart = '';

    // Generate chart in best-effort mode; signup should not fail if this step fails.
    try {
      final chartInfo = await ZodiacHelper.generateBirthChart(
        dob,
        name: model.name,
        placeOfBirth: model.place,
        hour: model.hour,
        minute: model.minute,
        isAM: model.isAM,
      ).timeout(const Duration(seconds: 18));

      model.tempChartId = chartInfo['tempChartId'] ?? '';
      zodiacFromChart = chartInfo['rashi'] ?? '';
    } catch (_) {
      model.tempChartId = '';
      zodiacFromChart = '';
    }

    final url = Uri.parse('$baseurl/user/signup/astrology');
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    final rawBody = response.body;
    final dynamic decoded = rawBody.isNotEmpty
        ? jsonDecode(rawBody)
        : <String, dynamic>{};
    final res = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'message': rawBody};

    if (response.statusCode == 200 || response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();

      final token = res['token'] ?? '';
      final refreshToken = res['refreshToken'] ?? '';
      final user = res['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final userId = user['id']?.toString() ?? user['_id']?.toString() ?? '';

      await prefs.setString('auth_token', token);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('userId', userId);
      await prefs.setString('sessionId', user['sessionId']?.toString() ?? '');
      await prefs.setString('userName', user['name']?.toString() ?? model.name);
      await prefs.setString('userPhone', user['phone']?.toString() ?? phone);
      await prefs.setString(
        'userEmail',
        user['email']?.toString() ?? payload['email']?.toString() ?? '',
      );
      await prefs.setBool('isLoggedIn', true);

      final zodiacFromUser = AstrologyFlowHelper.resolveZodiacFromUser(user);
      final rashi = zodiacFromUser.isNotEmpty
          ? zodiacFromUser
          : (zodiacFromChart.isNotEmpty ? zodiacFromChart : 'unknown');
      await prefs.setString('vedic_rashi', rashi);

      final bundle = await _safeHoroscopeBundle(rashi);
      final dailyData = HoroscopeData.fromJson(bundle['daily']!);
      final weeklyData = HoroscopeData.fromJson(bundle['weekly']!);
      final monthlyData = HoroscopeData.fromJson(bundle['monthly']!);

      // Save horoscope data locally
      await prefs.setString('zodiacSign', rashi);
      await prefs.setString('daily', jsonEncode(dailyData.toJson()));
      await prefs.setString('weekly', jsonEncode(weeklyData.toJson()));
      await prefs.setString('monthly', jsonEncode(monthlyData.toJson()));

      try {
        await ProfileService.fetchMyProfile();
      } catch (_) {
        // Keep signup success even if profile sync is temporarily unavailable.
      }

      return {
        'token': token,
        'refreshToken': refreshToken,
        'zodiacSign': rashi,
        'tempChartId': model.tempChartId,
        'daily': dailyData,
        'weekly': weeklyData,
        'monthly': monthlyData,
      };
    }

    final message =
        res['message']?.toString() ??
        res['error']?.toString() ??
        'Signup failed (${response.statusCode})';
    throw Exception(message);
  }

  Future<Map<String, Map<String, dynamic>>> _safeHoroscopeBundle(
    String zodiac,
  ) async {
    final fallback = <String, Map<String, dynamic>>{
      'daily': <String, dynamic>{'title': 'Today', 'horoscope': ''},
      'weekly': <String, dynamic>{'title': 'This Week', 'horoscope': ''},
      'monthly': <String, dynamic>{'title': 'This Month', 'horoscope': ''},
    };

    if (zodiac.isEmpty || zodiac == 'unknown') {
      return fallback;
    }

    try {
      final bundle = await AstrologyFlowHelper.fetchHoroscopeBundle(
        zodiac,
      ).timeout(const Duration(seconds: 22));
      return <String, Map<String, dynamic>>{
        'daily':
            (bundle['daily'] as Map<String, dynamic>? ?? fallback['daily']!),
        'weekly':
            (bundle['weekly'] as Map<String, dynamic>? ?? fallback['weekly']!),
        'monthly':
            (bundle['monthly'] as Map<String, dynamic>? ??
            fallback['monthly']!),
      };
    } catch (_) {
      return fallback;
    }
  }
}
