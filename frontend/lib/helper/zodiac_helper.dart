import 'dart:convert';
import 'package:astro_tale/core/constants/api_constants.dart';
import 'package:astro_tale/helper/chart_cache_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ZodiacHelper {
  /// Generate birth chart and return both rashi and temporary chart id
  static Future<Map<String, String>> generateBirthChart(
    DateTime dob, {
    String name = "User",
    String gender = "male",
    String placeOfBirth = "Unknown",
    int hour = 0,
    int minute = 0,
    bool isAM = true,
    String astrologyType = "vedic",
    String ayanamsa = "lahiri",
  }) async {
    try {
      final payload = {
        "name": name,
        "gender": gender,
        "birth_date": {"year": dob.year, "month": dob.month, "day": dob.day},
        "birth_time": {
          "hour": hour,
          "minute": minute,
          "ampm": isAM ? "AM" : "PM",
        },
        "place_of_birth": placeOfBirth,
        "astrology_type": astrologyType,
        "ayanamsa": ayanamsa,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.birthChartGenerateApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("API Error: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);
      final chartData = data['data'] ?? {};

      // Extract rashi & temp chart id
      final rashi =
          (chartData['rashi'] ?? chartData['ascendant']?['sign'] ?? "")
              .toString()
              .toLowerCase();
      final tempChartId = chartData['_id'] ?? chartData['id'] ?? '';
      final chartImage = chartData["chartImage"]?.toString();

      // Save rashi locally
      if (rashi.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("vedic_rashi", rashi);
      }

      await ChartCacheHelper.cacheChart(
        chartData: chartData["chartData"] is Map
            ? Map<String, dynamic>.from(chartData["chartData"] as Map)
            : <String, dynamic>{},
        chartImage: chartImage,
        fallbackRashi: rashi,
      );

      return {
        'rashi': rashi.isNotEmpty ? rashi : 'unknown',
        'tempChartId': tempChartId,
      };
    } catch (e) {
      print("Error generating birth chart: $e");
      return {'rashi': 'unknown', 'tempChartId': ''};
    }
  }

  /// Get stored Rashi
  static Future<String?> getStoredRashi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("vedic_rashi");
  }
}
