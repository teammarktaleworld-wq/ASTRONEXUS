import "dart:async";
import "dart:convert";

import "package:astro_tale/App/Model/Horoscope/horoscope_model.dart";
import "package:astro_tale/App/views/dash/DashboardScreen.dart";
import "package:astro_tale/helper/Astrology_flow_helper.dart";
import "package:astro_tale/helper/chart_cache_helper.dart";
import "package:astro_tale/services/api_services/chatbot/profile_services.dart";
import "package:flutter/material.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../../controller/Auth_Controller.dart";
import "../helper/login_api.dart";

class LoginController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Timer? _timer;
  int _secondsLeft = 0;

  bool get isLocked => _secondsLeft > 0;
  int get secondsLeft => _secondsLeft;

  void _startTimer() {
    _secondsLeft = 30;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsLeft--;
      notifyListeners();

      if (_secondsLeft <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> login(
    BuildContext context,
    String phone,
    String password,
  ) async {
    if (isLocked) {
      errorMessage = "Too many attempts. Try again in $secondsLeft sec";
      notifyListeners();
      return;
    }

    if (phone.isEmpty || password.isEmpty) {
      errorMessage = "Enter phone and password";
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await LoginApi.loginWithPhone(
        phone: phone,
        password: password,
      );

      if (response["token"] == null) {
        throw Exception(response["message"] ?? "Token missing");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = response["token"]?.toString() ?? "";
      final refreshToken = response["refreshToken"]?.toString() ?? "";
      final user = _asMap(response["user"]);
      final userId = (user["id"] ?? user["_id"] ?? "").toString();

      await prefs.setString("auth_token", token);
      await prefs.setString("refresh_token", refreshToken);
      await prefs.setString("userName", user["name"]?.toString() ?? "");
      await prefs.setString("userEmail", user["email"]?.toString() ?? "");
      await prefs.setString("userPhone", user["phone"]?.toString() ?? "");
      await prefs.setString("userId", userId);
      await prefs.setString("role", user["role"]?.toString() ?? "");
      await prefs.setString(
        "userAvatar",
        _resolveAvatar(user["profileImage"]) ?? "",
      );
      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("sessionId", user["sessionId"]?.toString() ?? "");

      AuthController.token = token;
      AuthController.userId = userId;
      AuthController.role = user["role"]?.toString() ?? "";

      if (JwtDecoder.isExpired(token)) {
        throw Exception("Session expired. Please login again.");
      }

      await _cacheChartFromPayload(user);

      final profile = _asMap(user["astrologyProfile"]);
      final dobString = profile["dateOfBirth"]?.toString();
      final timeString = profile["timeOfBirth"]?.toString() ?? "00:00";
      final place = profile["placeOfBirth"]?.toString() ?? "Unknown";
      final gender = user["gender"]?.toString() ?? "male";

      if (dobString != null && dobString.isNotEmpty) {
        await prefs.setString("dob", dobString);
      }
      await prefs.setString("tob", timeString);
      await prefs.setString("pob", place);

      final zodiacFromUser = AstrologyFlowHelper.resolveZodiacFromUser(user);
      final astroData = await _loadAstroData(
        user: user,
        zodiacFromUser: zodiacFromUser,
        dobString: dobString,
        timeString: timeString,
        place: place,
        gender: gender,
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

      try {
        await ProfileService.fetchMyProfile();
      } catch (_) {
        // Keep login successful even if profile sync fails temporarily.
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
    } on TimeoutException {
      _startTimer();
      errorMessage = "Server timeout. Try again in 30 seconds.";
      notifyListeners();
    } on Exception catch (e) {
      _startTimer();
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    } catch (_) {
      _startTimer();
      errorMessage = "Login failed. Try again later.";
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _loadAstroData({
    required Map<String, dynamic> user,
    required String zodiacFromUser,
    required String? dobString,
    required String timeString,
    required String place,
    required String gender,
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
      throw Exception("Birth details missing in profile");
    }

    final dob = DateTime.parse(dobString);
    final parts = timeString.split(":");
    final hour24 =
        int.tryParse(parts.first.replaceAll(RegExp(r"[^0-9]"), "")) ?? 0;
    final minute = parts.length > 1
        ? int.tryParse(parts[1].replaceAll(RegExp(r"[^0-9]"), "")) ?? 0
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

  Future<void> _cacheChartFromPayload(Map<String, dynamic> user) async {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _resolveAvatar(dynamic profileImage) {
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }
}
