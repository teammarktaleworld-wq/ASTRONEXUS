import "dart:convert";

import "package:astro_tale/core/constants/api_constants.dart";
import "package:shared_preferences/shared_preferences.dart";

class ChartCacheHelper {
  const ChartCacheHelper._();

  static String resolveChartImageUrl(
    String? chartImagePath, {
    String baseUrl = ApiConstants.baseUrl,
  }) {
    final candidates = resolveChartImageCandidates(
      chartImagePath,
      baseUrl: baseUrl,
    );
    if (candidates.isEmpty) {
      return "";
    }
    return candidates.first;
  }

  static List<String> resolveChartImageCandidates(
    String? chartImagePath, {
    String baseUrl = ApiConstants.baseUrl,
  }) {
    final value = chartImagePath?.trim() ?? "";
    if (value.isEmpty) {
      return const <String>[];
    }
    if (value.startsWith("http://") || value.startsWith("https://")) {
      return <String>[value];
    }

    final normalizedPath = value.startsWith("/") ? value : "/$value";
    final origins = <String>{
      _origin(baseUrl),
      _origin(ApiConstants.birthChartGenerateApi),
      _origin(ApiConstants.birthChartApi),
      _origin(ApiConstants.legacyBirthChartApi),
      ...ApiConstants.birthChartImageBaseCandidates.map(_origin),
    }..removeWhere((origin) => origin.isEmpty);

    final candidates = <String>[];
    for (final origin in origins) {
      try {
        final resolved = Uri.parse(origin).resolve(normalizedPath).toString();
        if (!candidates.contains(resolved)) {
          candidates.add(resolved);
        }
      } catch (_) {
        // Ignore malformed origins and continue with valid candidates.
      }
    }

    if (candidates.isNotEmpty) {
      return candidates;
    }
    return <String>[Uri.parse(baseUrl).resolve(normalizedPath).toString()];
  }

  static Future<void> cacheChart({
    required Map<String, dynamic> chartData,
    String? chartImage,
    List<dynamic>? allCharts,
    String? fallbackRashi,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final rawImage = chartImage?.trim() ?? "";
    final resolvedImage = resolveChartImageUrl(rawImage);
    if (rawImage.isNotEmpty) {
      await prefs.setString("chartImage", rawImage);
    } else if (resolvedImage.isNotEmpty) {
      await prefs.setString("chartImage", resolvedImage);
    }
    if (resolvedImage.isNotEmpty) {
      await prefs.setString("chartImageResolved", resolvedImage);
    }

    final planets = _asMap(chartData["planets"]);
    final ascendant = _asMap(chartData["ascendant"]);
    final moon = _asMap(chartData["Moon"]).isNotEmpty
        ? _asMap(chartData["Moon"])
        : _asMap(planets["Moon"]);
    final sun = _asMap(chartData["Sun"]).isNotEmpty
        ? _asMap(chartData["Sun"])
        : _asMap(planets["Sun"]);
    final houses = _asMap(chartData["houses"]);
    final dashas = _asMap(chartData["dashas"]);

    final rashi =
        (chartData["rashi"] ??
                fallbackRashi ??
                moon["sign"] ??
                ascendant["sign"] ??
                "")
            .toString()
            .trim();

    if (rashi.isNotEmpty) {
      await prefs.setString("zodiacSign", rashi);
      await prefs.setString("vedic_rashi", rashi.toLowerCase());
    }

    await prefs.setString(
      "nakshatra",
      chartData["nakshatra"]?.toString() ?? "",
    );
    await prefs.setString("lagnam", ascendant["sign"]?.toString() ?? "");
    await prefs.setString("moonSign", moon["sign"]?.toString() ?? "");
    await prefs.setString("sunSign", sun["sign"]?.toString() ?? "");

    await prefs.setString("planets", jsonEncode(planets));
    await prefs.setString("houses", jsonEncode(houses));
    await prefs.setString("dashas", jsonEncode(dashas));
    await prefs.setInt("planetCount", planets.length);
    await prefs.setInt("houseCount", houses.length);

    if (allCharts != null) {
      await prefs.setString("allCharts", jsonEncode(allCharts));
    }
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

  static String _origin(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || uri.host.isEmpty) {
        return "";
      }
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
      ).toString();
    } catch (_) {
      return "";
    }
  }
}
