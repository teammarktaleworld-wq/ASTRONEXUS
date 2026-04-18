import "dart:async";
import "dart:convert";

import "package:astro_tale/App/views/Auth/login_phone__pass/screen/login_phone_screen.dart";
import "package:astro_tale/App/Model/Horoscope/horoscope_model.dart";
import "package:astro_tale/App/views/dash/DashboardScreen.dart";
import "package:astro_tale/App/views/onboard/Screens/onboarding.dart";
import "package:astro_tale/core/constants/app_assets.dart";
import "package:astro_tale/helper/Astrology_flow_helper.dart";
import "package:astro_tale/services/api_services/chatbot/profile_services.dart";
import "package:flutter/material.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../controller/Auth_Controller.dart";

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final onboardingSeen = prefs.getBool("onboarding_seen") ?? false;
    String? token = prefs.getString("auth_token");

    AuthController.token = token ?? "";
    AuthController.refreshToken = prefs.getString("refresh_token") ?? "";
    AuthController.userId = prefs.getString("userId") ?? "";
    AuthController.role = prefs.getString("role") ?? "";

    if (token != null && JwtDecoder.isExpired(token)) {
      token = null;
      AuthController.token = "";
      await prefs.remove("auth_token");
      await prefs.remove("refresh_token");
    }

    if (!mounted) {
      return;
    }

    if (token != null) {
      String zodiacSign = prefs.getString("zodiacSign") ?? "";
      HoroscopeData daily = HoroscopeData.fromJson(
        _safeJsonMap(prefs.getString("daily")),
      );
      HoroscopeData weekly = HoroscopeData.fromJson(
        _safeJsonMap(prefs.getString("weekly")),
      );
      HoroscopeData monthly = HoroscopeData.fromJson(
        _safeJsonMap(prefs.getString("monthly")),
      );

      final missingLocalData =
          zodiacSign.isEmpty ||
          daily.text.trim().isEmpty ||
          weekly.text.trim().isEmpty ||
          monthly.text.trim().isEmpty;

      if (missingLocalData) {
        try {
          await ProfileService.fetchMyProfile();
          zodiacSign = prefs.getString("zodiacSign") ?? zodiacSign;
        } catch (_) {
          // Continue with cached data when profile sync fails.
        }
      }

      if (zodiacSign.isNotEmpty &&
          (daily.text.trim().isEmpty ||
              weekly.text.trim().isEmpty ||
              monthly.text.trim().isEmpty)) {
        try {
          final bundle = await AstrologyFlowHelper.fetchHoroscopeBundle(
            zodiacSign,
          );
          daily = HoroscopeData.fromJson(
            bundle["daily"] as Map<String, dynamic>,
          );
          weekly = HoroscopeData.fromJson(
            bundle["weekly"] as Map<String, dynamic>,
          );
          monthly = HoroscopeData.fromJson(
            bundle["monthly"] as Map<String, dynamic>,
          );

          await prefs.setString("daily", jsonEncode(daily.toJson()));
          await prefs.setString("weekly", jsonEncode(weekly.toJson()));
          await prefs.setString("monthly", jsonEncode(monthly.toJson()));
        } catch (_) {
          // Keep opening app with existing cached values.
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            zodiacSign: zodiacSign,
            daily: daily,
            weekly: weekly,
            monthly: monthly,
          ),
        ),
      );
    } else if (!onboardingSeen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPhoneScreen()),
      );
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xff050B1E),
              Color(0xff1B1A3A),
              Color(0xff050B1E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color(0xff1B1A3A),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Image.asset(AppAssets.logo, width: 140),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _safeJsonMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // keep empty fallback
    }
    return <String, dynamic>{};
  }
}
