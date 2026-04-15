import "dart:convert";

import "package:astro_tale/core/constants/api_constants.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class ChatbotService {
  const ChatbotService._();

  static const String baseUrl = ApiConstants.chatbotAskApi;

  static Future<MatiChatResponse> askQuestion(String question) async {
    final prefs = await SharedPreferences.getInstance();

    final sessionId = (prefs.getString("sessionId") ?? "astro-session").trim();
    final token = (prefs.getString("auth_token") ?? "").trim();

    final headers = <String, String>{"Content-Type": "application/json"};
    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: headers,
          body: jsonEncode(<String, dynamic>{
            "sessionId": sessionId.isEmpty ? "astro-session" : sessionId,
            "message": question,
          }),
        )
        .timeout(const Duration(seconds: 25));

    final decoded = jsonDecode(response.body);
    final data = _asStringDynamicMap(decoded);

    if (response.statusCode == 200) {
      final parsed = MatiChatResponse.fromApiJson(data);
      if (parsed.answer.isNotEmpty || parsed.ok || parsed.success) {
        return parsed;
      }
    }

    debugPrint("Chatbot error ${response.statusCode}: ${response.body}");
    throw Exception(data["message"] ?? "Server error");
  }

  static Map<String, dynamic> _asStringDynamicMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }
}

class MatiChatResponse {
  const MatiChatResponse({
    required this.success,
    required this.service,
    required this.ok,
    required this.answer,
    this.analysis,
    this.uiMetadata,
    this.shopSuggestions = const <MatiShopSuggestion>[],
    this.raw = const <String, dynamic>{},
  });

  final bool success;
  final String service;
  final bool ok;
  final String answer;
  final MatiAnalysis? analysis;
  final MatiUiMetadata? uiMetadata;
  final List<MatiShopSuggestion> shopSuggestions;
  final Map<String, dynamic> raw;

  bool get hasRichData =>
      analysis != null || uiMetadata != null || shopSuggestions.isNotEmpty;

  factory MatiChatResponse.fromApiJson(Map<String, dynamic> json) {
    final data = _asStringDynamicMap(json["data"]).isEmpty
        ? json
        : _asStringDynamicMap(json["data"]);

    final analysisMap = _asStringDynamicMap(data["analysis"]);
    final uiMetadataMap = _asStringDynamicMap(data["uiMetadata"]);
    final shopRaw = data["shopSuggestions"];
    final suggestions = <MatiShopSuggestion>[];
    if (shopRaw is List) {
      for (final item in shopRaw) {
        final mapItem = _asStringDynamicMap(item);
        if (mapItem.isNotEmpty) {
          suggestions.add(MatiShopSuggestion.fromJson(mapItem));
        }
      }
    }

    return MatiChatResponse(
      success: _asBool(json["success"]),
      service: json["service"]?.toString() ?? "",
      ok: _asBool(data["ok"]),
      answer: data["answer"]?.toString() ?? json["answer"]?.toString() ?? "",
      analysis: analysisMap.isEmpty ? null : MatiAnalysis.fromJson(analysisMap),
      uiMetadata: uiMetadataMap.isEmpty
          ? null
          : MatiUiMetadata.fromJson(uiMetadataMap),
      shopSuggestions: suggestions,
      raw: json,
    );
  }
}

class MatiAnalysis {
  const MatiAnalysis({
    required this.decisionScore,
    required this.positivePercentage,
    required this.negativePercentage,
    this.planetBreakdown = const <MatiPlanetInsight>[],
  });

  final double decisionScore;
  final double positivePercentage;
  final double negativePercentage;
  final List<MatiPlanetInsight> planetBreakdown;

  factory MatiAnalysis.fromJson(Map<String, dynamic> json) {
    final rawPlanets = json["planetBreakdown"];
    final planets = <MatiPlanetInsight>[];
    if (rawPlanets is List) {
      for (final item in rawPlanets) {
        final mapItem = _asStringDynamicMap(item);
        if (mapItem.isNotEmpty) {
          planets.add(MatiPlanetInsight.fromJson(mapItem));
        }
      }
    }

    return MatiAnalysis(
      decisionScore: _toDouble(json["decisionScore"]),
      positivePercentage: _toDouble(json["positivePercentage"]),
      negativePercentage: _toDouble(json["negativePercentage"]),
      planetBreakdown: planets,
    );
  }
}

class MatiPlanetInsight {
  const MatiPlanetInsight({
    required this.planet,
    required this.status,
    required this.strength,
    required this.reason,
  });

  final String planet;
  final String status;
  final double strength;
  final String reason;

  bool get isPositive => status.toLowerCase() == "positive";

  factory MatiPlanetInsight.fromJson(Map<String, dynamic> json) {
    return MatiPlanetInsight(
      planet: json["planet"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      strength: _toDouble(json["strength"]),
      reason: json["reason"]?.toString() ?? "",
    );
  }
}

class MatiUiMetadata {
  const MatiUiMetadata({
    required this.type,
    required this.verdict,
    required this.color,
    required this.action,
    required this.summary,
    this.labels = const <String, String>{},
  });

  final String type;
  final String verdict;
  final String color;
  final String action;
  final String summary;
  final Map<String, String> labels;

  factory MatiUiMetadata.fromJson(Map<String, dynamic> json) {
    final parsedLabels = <String, String>{};
    final labelsMap = _asStringDynamicMap(json["labels"]);
    labelsMap.forEach((key, value) {
      parsedLabels[key] = value?.toString() ?? "";
    });
    return MatiUiMetadata(
      type: json["type"]?.toString() ?? "",
      verdict: json["verdict"]?.toString() ?? "",
      color: json["color"]?.toString() ?? "",
      action: json["action"]?.toString() ?? "",
      summary: json["summary"]?.toString() ?? "",
      labels: parsedLabels,
    );
  }
}

class MatiShopSuggestion {
  const MatiShopSuggestion({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.tags,
    required this.shopUrl,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String category;
  final List<String> tags;
  final String shopUrl;

  factory MatiShopSuggestion.fromJson(Map<String, dynamic> json) {
    return MatiShopSuggestion(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      price: _toDouble(json["price"]),
      currency: json["currency"]?.toString() ?? "",
      category: json["category"]?.toString() ?? "",
      tags: _toStringList(json["tags"]),
      shopUrl: json["shopUrl"]?.toString() ?? "",
    );
  }
}

Map<String, dynamic> _asStringDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item?.toString() ?? "")
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == "true";
  }
  if (value is num) {
    return value != 0;
  }
  return false;
}
