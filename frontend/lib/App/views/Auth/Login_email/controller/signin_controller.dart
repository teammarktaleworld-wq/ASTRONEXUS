import "dart:convert";

import "package:astro_tale/App/Model/Horoscope/horoscope_model.dart";
import "package:astro_tale/helper/Astrology_flow_helper.dart";
import "package:astro_tale/helper/chart_cache_helper.dart";
import "package:astro_tale/services/API/APIservice.dart";
import "package:astro_tale/services/api_services/chatbot/profile_services.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../../../../controller/Auth_Controller.dart";
import "../../../dash/DashboardScreen.dart";

class SignInController {
  static Future<void> login({
    required BuildContext context,
    required TextEditingController email,
    required TextEditingController password,
    required bool rememberMe,
    required VoidCallback onStart,
    required VoidCallback onStop,
  }) async {
    if (email.text.isEmpty || password.text.isEmpty) {
      _snack(context, "Fill all fields");
      return;
    }

    onStart();

    try {
      final res = await http.post(
        Uri.parse("$baseurl/user/login"),
        headers: <String, String>{"Content-Type": "application/json"},
        body: jsonEncode(<String, String>{
          "email": email.text.trim(),
          "password": password.text.trim(),
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || data["token"] == null) {
        if (context.mounted) {
          _snack(context, data["message"]?.toString() ?? "Login failed");
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = data["token"]?.toString() ?? "";
      final refreshToken = data["refreshToken"]?.toString() ?? "";
      final user = _asMap(data["user"]);
      final userId = (user["id"] ?? user["_id"] ?? "").toString();
      final role = user["role"]?.toString() ?? "";

      await prefs.setString("auth_token", token);
      await prefs.setString("refresh_token", refreshToken);
      await prefs.setString("userName", user["name"]?.toString() ?? "");
      await prefs.setString("userEmail", user["email"]?.toString() ?? "");
      await prefs.setString("userPhone", user["phone"]?.toString() ?? "");
      await prefs.setString(
        "userAvatar",
        _resolveAvatar(user["profileImage"]) ??
            user["avatar"]?.toString() ??
            "",
      );
      await prefs.setString("userId", userId);
      await prefs.setString("role", role);
      await prefs.setString("sessionId", user["sessionId"]?.toString() ?? "");
      await prefs.setBool("isLoggedIn", true);

      AuthController.token = token;

      await _cacheChartFromPayload(user);

      final profile = _asMap(user["astrologyProfile"]);
      final dobString = profile["dateOfBirth"]?.toString();
      final gender = profile["gender"]?.toString() ?? "male";
      final place = profile["placeOfBirth"]?.toString() ?? "Unknown";
      final timeString = profile["timeOfBirth"]?.toString() ?? "00:00";

      final zodiacFromUser = AstrologyFlowHelper.resolveZodiacFromUser(user);
      final astroData = await _loadAstroData(
        user: user,
        zodiacFromUser: zodiacFromUser,
        dobString: dobString,
        gender: gender,
        place: place,
        timeString: timeString,
      );

      final dailyData = HoroscopeData.fromJson(_asMap(astroData["daily"]));
      final weeklyData = HoroscopeData.fromJson(_asMap(astroData["weekly"]));
      final monthlyData = HoroscopeData.fromJson(_asMap(astroData["monthly"]));

      await prefs.setString(
        "zodiacSign",
        astroData["zodiac"]?.toString() ?? "",
      );
      await prefs.setString("daily", jsonEncode(dailyData.toJson()));
      await prefs.setString("weekly", jsonEncode(weeklyData.toJson()));
      await prefs.setString("monthly", jsonEncode(monthlyData.toJson()));
      if (dobString != null && dobString.isNotEmpty) {
        await prefs.setString("dob", dobString);
      }
      await prefs.setString("tob", timeString);
      await prefs.setString("pob", place);

      try {
        await ProfileService.fetchMyProfile();
      } catch (_) {
        // Do not block login on profile sync failures.
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              zodiacSign: astroData["zodiac"]?.toString() ?? "",
              daily: dailyData,
              weekly: weeklyData,
              monthly: monthlyData,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, e.toString());
      }
    } finally {
      onStop();
    }
  }

  static Future<Map<String, dynamic>> _loadAstroData({
    required Map<String, dynamic> user,
    required String zodiacFromUser,
    required String? dobString,
    required String gender,
    required String place,
    required String timeString,
  }) async {
    if (zodiacFromUser.isNotEmpty) {
      final bundle = await AstrologyFlowHelper.fetchHoroscopeBundle(
        zodiacFromUser,
      );
      return <String, dynamic>{
        "zodiac": zodiacFromUser,
        "daily": bundle["daily"],
        "weekly": bundle["weekly"],
        "monthly": bundle["monthly"],
      };
    }

    if (dobString == null || dobString.isEmpty) {
      return <String, dynamic>{
        "zodiac": "",
        "daily": const <String, dynamic>{"title": "Today", "horoscope": ""},
        "weekly": const <String, dynamic>{
          "title": "This Week",
          "horoscope": "",
        },
        "monthly": const <String, dynamic>{
          "title": "This Month",
          "horoscope": "",
        },
      };
    }

    final dob = DateTime.parse(dobString);
    final timeParts = timeString.split(":");
    final hour24 =
        int.tryParse(timeParts.first.replaceAll(RegExp(r"[^0-9]"), "")) ?? 0;
    final minute = timeParts.length > 1
        ? int.tryParse(timeParts[1].replaceAll(RegExp(r"[^0-9]"), "")) ?? 0
        : 0;
    final isAM = hour24 < 12;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return AstrologyFlowHelper.prepareDashboardData(
      dob: dob,
      name: user["name"]?.toString() ?? "User",
      gender: gender,
      placeOfBirth: place,
      hour: hour12,
      minute: minute,
      isAM: isAM,
    );
  }

  static Future<void> _cacheChartFromPayload(Map<String, dynamic> user) async {
    final charts = user["charts"] as List<dynamic>? ?? const <dynamic>[];
    if (charts.isEmpty) {
      return;
    }

    final parsed = charts
        .map(_asMap)
        .where((chart) => chart.isNotEmpty)
        .toList(growable: false);
    if (parsed.isEmpty) {
      return;
    }

    parsed.sort((a, b) {
      final left =
          DateTime.tryParse(a["createdAt"]?.toString() ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final right =
          DateTime.tryParse(b["createdAt"]?.toString() ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });

    final latest = parsed.first;
    await ChartCacheHelper.cacheChart(
      chartData: _asMap(latest["chartData"]),
      chartImage:
          latest["chartImage"]?.toString() ??
          latest["chartImageUrl"]?.toString(),
      allCharts: charts,
      fallbackRashi: latest["rashi"]?.toString(),
    );
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static String? _resolveAvatar(dynamic profileImage) {
    if (profileImage is! Map<String, dynamic>) {
      return null;
    }
    if (profileImage["url"] != null) {
      return profileImage["url"].toString();
    }
    if (profileImage["publicId"] != null) {
      return "https://res.cloudinary.com/dgad4eoty/image/upload/${profileImage["publicId"]}";
    }
    return null;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }
}
