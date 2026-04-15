import 'dart:convert';
import 'package:astro_tale/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class HoroscopeApi {
  static const String _baseUrl = ApiConstants.horoscopeBaseUrl;
  static Future<Map<String, dynamic>> fetchHoroscope({
    required String sign,
    required String type,
  }) async {
    final normalizedSign = sign.trim().toLowerCase();
    final normalizedType = type.trim().toLowerCase();
    final endpoints = <String>[
      _baseUrl,
      ApiConstants.legacyHoroscopeBaseUrl,
    ].toSet().toList(growable: false);

    Object? lastError;

    for (final endpoint in endpoints) {
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          final uri = Uri.parse(endpoint).replace(
            queryParameters: <String, String>{
              "sign": normalizedSign,
              "type": normalizedType,
            },
          );

          final timeout = Duration(seconds: 14 + (attempt * 8));
          final response = await http.get(uri).timeout(timeout);
          if (response.statusCode != 200) {
            lastError = Exception(
              "Failed to load horoscope (${response.statusCode})",
            );
            continue;
          }

          final parsed = _parseBody(response.body, normalizedType);
          final text = parsed["horoscope"]?.toString().trim() ?? "";
          if (text.isNotEmpty) {
            return parsed;
          }
          lastError = Exception("Horoscope payload was empty");
        } catch (e) {
          lastError = e;
        }
      }
    }

    return _fallback(
      sign: normalizedSign,
      type: normalizedType,
      error: lastError,
    );
  }

  static Map<String, dynamic> _parseBody(String body, String type) {
    final decoded = json.decode(body);
    final root = _asMap(decoded);
    final rootData = _asMap(root["data"]);
    final nestedData = _asMap(rootData["data"]);

    final fromRootType = _asMap(root[type]);
    final fromDataType = _asMap(rootData[type]);
    final fromNestedType = _asMap(nestedData[type]);
    final scoped = fromDataType.isNotEmpty
        ? fromDataType
        : (fromRootType.isNotEmpty
              ? fromRootType
              : (fromNestedType.isNotEmpty
                    ? fromNestedType
                    : (nestedData.isNotEmpty ? nestedData : rootData)));

    final title = _titleFor(type, scoped);
    final horoscope = _extractText(scoped);

    if (type == "monthly") {
      final nestedScoped = _asMap(scoped["data"]);
      final deepScoped = _asMap(nestedScoped["data"]);
      return {
        "title": title,
        "horoscope": horoscope,
        "extra": {
          "standout_days": _asStringList(
            scoped["standout_days"] ??
                scoped["standoutDays"] ??
                nestedScoped["standout_days"] ??
                nestedScoped["standoutDays"] ??
                deepScoped["standout_days"] ??
                deepScoped["standoutDays"] ??
                nestedData["standout_days"] ??
                nestedData["standoutDays"],
          ),
          "challenging_days": _asStringList(
            scoped["challenging_days"] ??
                scoped["challengingDays"] ??
                nestedScoped["challenging_days"] ??
                nestedScoped["challengingDays"] ??
                deepScoped["challenging_days"] ??
                deepScoped["challengingDays"] ??
                nestedData["challenging_days"] ??
                nestedData["challengingDays"],
          ),
        },
      };
    }

    return {"title": title, "horoscope": horoscope, "extra": null};
  }

  static String _titleFor(String type, Map<String, dynamic> data) {
    final nested = _asMap(data["data"]);
    final deepNested = _asMap(nested["data"]);
    switch (type) {
      case "daily":
        return _firstNonEmptyString(<dynamic>[
          data["date"],
          nested["date"],
          deepNested["date"],
          data["title"],
          nested["title"],
          deepNested["title"],
        ], "Today");
      case "weekly":
        return _firstNonEmptyString(<dynamic>[
          data["week"],
          nested["week"],
          deepNested["week"],
          data["title"],
          nested["title"],
          deepNested["title"],
        ], "This Week");
      case "monthly":
        return _firstNonEmptyString(<dynamic>[
          data["month"],
          nested["month"],
          deepNested["month"],
          data["title"],
          nested["title"],
          deepNested["title"],
        ], "This Month");
      default:
        return _firstNonEmptyString(<dynamic>[
          data["title"],
          nested["title"],
          deepNested["title"],
        ]);
    }
  }

  static String _extractText(Map<String, dynamic> data) {
    final nested = _asMap(data["data"]);
    final deepNested = _asMap(nested["data"]);
    return _firstNonEmptyString(<dynamic>[
      data["horoscope_data"],
      data["horoscope"],
      data["prediction"],
      data["text"],
      data["content"],
      data["message"],
      nested["horoscope_data"],
      nested["horoscope"],
      nested["prediction"],
      nested["text"],
      nested["content"],
      nested["message"],
      deepNested["horoscope_data"],
      deepNested["horoscope"],
      deepNested["prediction"],
      deepNested["text"],
      deepNested["content"],
      deepNested["message"],
    ]);
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    if (value == null) {
      return const <String>[];
    }
    final single = value.toString().trim();
    if (single.isEmpty) {
      return const <String>[];
    }
    return <String>[single];
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

  static String _firstNonEmptyString(
    List<dynamic> values, [
    String fallback = "",
  ]) {
    for (final value in values) {
      final text = value?.toString().trim() ?? "";
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }

  static Map<String, dynamic> _fallback({
    required String sign,
    required String type,
    Object? error,
  }) {
    final normalizedSign = sign.toUpperCase();
    final unavailable = error == null ? "" : " (network)";
    switch (type) {
      case "daily":
        return {
          "title": "Today",
          "horoscope":
              "Horoscope not available today for $normalizedSign$unavailable",
          "extra": null,
        };
      case "weekly":
        return {
          "title": "This Week",
          "horoscope":
              "Horoscope not available this week for $normalizedSign$unavailable",
          "extra": null,
        };
      case "monthly":
        return {
          "title": "This Month",
          "horoscope":
              "Horoscope not available this month for $normalizedSign$unavailable",
          "extra": {
            "standout_days": <String>[],
            "challenging_days": <String>[],
          },
        };
      default:
        return {
          "title": "",
          "horoscope": "Horoscope not available",
          "extra": null,
        };
    }
  }
}
