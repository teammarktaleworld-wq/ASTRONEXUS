import "../services/api_services/horoscope_api.dart";
import "zodiac_helper.dart";

class AstrologyFlowHelper {
  const AstrologyFlowHelper._();

  /// Prepare full dashboard data by generating chart first.
  static Future<Map<String, dynamic>> prepareDashboardData({
    required DateTime dob,
    String name = "User",
    String gender = "male",
    String placeOfBirth = "Unknown",
    int hour = 0,
    int minute = 0,
    bool isAM = true,
  }) async {
    final chartInfo = await ZodiacHelper.generateBirthChart(
      dob,
      name: name,
      gender: gender,
      placeOfBirth: placeOfBirth,
      hour: hour,
      minute: minute,
      isAM: isAM,
    );

    final zodiacSign = (chartInfo["rashi"] ?? "unknown").toString();
    final tempChartId = (chartInfo["tempChartId"] ?? "").toString();
    final horoscopes = await fetchHoroscopeBundle(zodiacSign);

    return <String, dynamic>{
      "zodiac": zodiacSign,
      "tempChartId": tempChartId,
      "daily": horoscopes["daily"],
      "weekly": horoscopes["weekly"],
      "monthly": horoscopes["monthly"],
    };
  }

  /// Fetch only horoscope bundle for a known zodiac sign.
  static Future<Map<String, dynamic>> fetchHoroscopeBundle(
    String zodiacSign,
  ) async {
    Future<Map<String, dynamic>> safeFetch(String type) async {
      try {
        return await HoroscopeApi.fetchHoroscope(sign: zodiacSign, type: type);
      } catch (_) {
        return _fallbackHoroscope(type, zodiacSign);
      }
    }

    final responses = await Future.wait<Map<String, dynamic>>(
      <Future<Map<String, dynamic>>>[
        safeFetch("daily"),
        safeFetch("weekly"),
        safeFetch("monthly"),
      ],
    );

    return <String, dynamic>{
      "daily": responses[0],
      "weekly": responses[1],
      "monthly": responses[2],
    };
  }

  /// Try extracting zodiac sign directly from user payload to avoid extra chart calls.
  static String resolveZodiacFromUser(Map<String, dynamic> user) {
    final astrology = _asMap(user["astrologyProfile"]);
    final direct =
        (astrology["rashi"] ??
                astrology["zodiac"] ??
                astrology["zodiacSign"] ??
                user["zodiacSign"])
            ?.toString()
            .trim();
    if (direct != null && direct.isNotEmpty) {
      return direct.toLowerCase();
    }

    final latestChart = _pickLatestChart(
      user["charts"] as List<dynamic>? ?? const <dynamic>[],
    );
    if (latestChart.isEmpty) {
      return "";
    }

    final chartData = _asMap(latestChart["chartData"]);
    final fallback =
        (latestChart["rashi"] ??
                chartData["rashi"] ??
                _asMap(chartData["ascendant"])["sign"])
            ?.toString()
            .trim();
    if (fallback == null || fallback.isEmpty) {
      return "";
    }
    return fallback.toLowerCase();
  }

  static Map<String, dynamic> _fallbackHoroscope(String type, String zodiac) {
    switch (type) {
      case "daily":
        return <String, dynamic>{
          "title": "Today",
          "horoscope": "Horoscope not available today for $zodiac",
          "extra": null,
        };
      case "weekly":
        return <String, dynamic>{
          "title": "This Week",
          "horoscope": "Horoscope not available this week for $zodiac",
          "extra": null,
        };
      case "monthly":
        return <String, dynamic>{
          "title": "This Month",
          "horoscope": "Horoscope not available this month for $zodiac",
          "extra": <String, List<String>>{
            "standout_days": <String>[],
            "challenging_days": <String>[],
          },
        };
      default:
        return <String, dynamic>{
          "title": "",
          "horoscope": "Horoscope not available",
          "extra": null,
        };
    }
  }

  static Map<String, dynamic> _pickLatestChart(List<dynamic> charts) {
    final parsed = charts
        .map(_asMap)
        .where((chart) => chart.isNotEmpty)
        .toList(growable: false);
    if (parsed.isEmpty) {
      return <String, dynamic>{};
    }
    parsed.sort((a, b) => _chartDate(b).compareTo(_chartDate(a)));
    return parsed.first;
  }

  static DateTime _chartDate(Map<String, dynamic> chart) {
    final raw = chart["createdAt"]?.toString();
    if (raw == null || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
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
