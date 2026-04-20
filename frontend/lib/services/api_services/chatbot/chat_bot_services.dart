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
    final birthDate = (prefs.getString("birthDate") ?? "").trim();
    final birthTime = (prefs.getString("birthTime") ?? "").trim();
    final birthPlace = (prefs.getString("birthPlace") ?? "").trim();
    final zodiacSign = (prefs.getString("zodiacSign") ?? "").trim();
    final userProfile = <String, dynamic>{};
    if (birthDate.isNotEmpty) {
      userProfile["birthDate"] = birthDate;
    }
    if (birthTime.isNotEmpty) {
      userProfile["birthTime"] = birthTime;
    }
    if (birthPlace.isNotEmpty) {
      userProfile["birthPlace"] = birthPlace;
    }
    if (zodiacSign.isNotEmpty) {
      userProfile["zodiacSign"] = zodiacSign;
    }

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
            if (userProfile.isNotEmpty) "userProfile": userProfile,
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
    throw Exception(data["error"] ?? data["message"] ?? "Server error");
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
    this.timing,
    this.report,
    this.uiMetadata,
    this.nutritionGuidance,
    this.shopSuggestions = const <MatiShopSuggestion>[],
    this.raw = const <String, dynamic>{},
  });

  final bool success;
  final String service;
  final bool ok;
  final String answer;
  final MatiAnalysis? analysis;
  final MatiTimingInfo? timing;
  final MatiReportData? report;
  final MatiUiMetadata? uiMetadata;
  final MatiNutritionGuidance? nutritionGuidance;
  final List<MatiShopSuggestion> shopSuggestions;
  final Map<String, dynamic> raw;

  bool get hasRichData =>
      analysis != null ||
      (timing?.hasContent ?? false) ||
      (report?.hasContent ?? false) ||
      uiMetadata != null ||
      nutritionGuidance != null ||
      shopSuggestions.isNotEmpty;

  factory MatiChatResponse.fromApiJson(Map<String, dynamic> json) {
    final data = _asStringDynamicMap(json["data"]).isEmpty
        ? json
        : _asStringDynamicMap(json["data"]);

    final analysisMap = _asStringDynamicMap(data["analysis"]);
    final timingMap = _asStringDynamicMap(data["timing"]);
    final reportMap = _asStringDynamicMap(data["report"]);
    final uiMetadataMap = _asStringDynamicMap(data["uiMetadata"]);
    final nutritionMap = _asStringDynamicMap(data["nutritionGuidance"]);
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
      timing: timingMap.isEmpty ? null : MatiTimingInfo.fromJson(timingMap),
      report: reportMap.isEmpty ? null : MatiReportData.fromJson(reportMap),
      uiMetadata: uiMetadataMap.isEmpty
          ? null
          : MatiUiMetadata.fromJson(uiMetadataMap),
      nutritionGuidance: nutritionMap.isEmpty
          ? null
          : MatiNutritionGuidance.fromJson(nutritionMap),
      shopSuggestions: suggestions,
      raw: json,
    );
  }
}

class MatiTimingInfo {
  const MatiTimingInfo({
    required this.requested,
    required this.exactDatePossible,
    required this.requiresBirthData,
    required this.favorableDates,
    required this.avoidDates,
    required this.note,
  });

  final bool requested;
  final bool exactDatePossible;
  final bool requiresBirthData;
  final List<MatiDateSuggestion> favorableDates;
  final List<MatiDateSuggestion> avoidDates;
  final String note;

  bool get hasContent =>
      favorableDates.isNotEmpty || avoidDates.isNotEmpty || note.isNotEmpty;

  factory MatiTimingInfo.fromJson(Map<String, dynamic> json) {
    return MatiTimingInfo(
      requested: _asBool(json["requested"]),
      exactDatePossible: _asBool(json["exactDatePossible"]),
      requiresBirthData: _asBool(json["requiresBirthData"]),
      favorableDates: _parseDateSuggestions(json["favorableDates"]),
      avoidDates: _parseDateSuggestions(json["avoidDates"]),
      note: json["note"]?.toString() ?? "",
    );
  }
}

class MatiDateSuggestion {
  const MatiDateSuggestion({
    required this.date,
    required this.label,
    required this.confidence,
    required this.reason,
  });

  final String date;
  final String label;
  final String confidence;
  final String reason;

  factory MatiDateSuggestion.fromJson(Map<String, dynamic> json) {
    return MatiDateSuggestion(
      date: json["date"]?.toString() ?? "",
      label: json["label"]?.toString() ?? "",
      confidence: json["confidence"]?.toString() ?? "",
      reason: json["reason"]?.toString() ?? "",
    );
  }
}

class MatiReportData {
  const MatiReportData({
    required this.requested,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.generatedOn,
    required this.fileName,
    required this.sections,
  });

  final bool requested;
  final String title;
  final String subtitle;
  final String summary;
  final String generatedOn;
  final String fileName;
  final List<MatiReportSection> sections;

  bool get hasContent =>
      title.isNotEmpty || summary.isNotEmpty || sections.isNotEmpty;

  factory MatiReportData.fromJson(Map<String, dynamic> json) {
    final rawSections = json["sections"];
    final sections = <MatiReportSection>[];
    if (rawSections is List) {
      for (final item in rawSections) {
        final mapItem = _asStringDynamicMap(item);
        if (mapItem.isNotEmpty) {
          sections.add(MatiReportSection.fromJson(mapItem));
        }
      }
    }

    return MatiReportData(
      requested: _asBool(json["requested"]),
      title: json["title"]?.toString() ?? "",
      subtitle: json["subtitle"]?.toString() ?? "",
      summary: json["summary"]?.toString() ?? "",
      generatedOn: json["generatedOn"]?.toString() ?? "",
      fileName: json["fileName"]?.toString() ?? "",
      sections: sections,
    );
  }
}

class MatiReportSection {
  const MatiReportSection({required this.heading, required this.content});

  final String heading;
  final String content;

  factory MatiReportSection.fromJson(Map<String, dynamic> json) {
    return MatiReportSection(
      heading: json["heading"]?.toString() ?? "",
      content: json["content"]?.toString() ?? "",
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

class MatiNutritionGuidance {
  const MatiNutritionGuidance({
    required this.focus,
    required this.foodsToFavor,
    required this.foodsToLimit,
    required this.mealSuggestion,
    required this.timingTip,
    required this.dominantPlanets,
    required this.note,
  });

  final String focus;
  final List<String> foodsToFavor;
  final List<String> foodsToLimit;
  final String mealSuggestion;
  final String timingTip;
  final List<String> dominantPlanets;
  final String note;

  factory MatiNutritionGuidance.fromJson(Map<String, dynamic> json) {
    return MatiNutritionGuidance(
      focus: json["focus"]?.toString() ?? "",
      foodsToFavor: _toStringList(json["foodsToFavor"]),
      foodsToLimit: _toStringList(json["foodsToLimit"]),
      mealSuggestion: json["mealSuggestion"]?.toString() ?? "",
      timingTip: json["timingTip"]?.toString() ?? "",
      dominantPlanets: _toStringList(json["dominantPlanets"]),
      note: json["note"]?.toString() ?? "",
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

List<MatiDateSuggestion> _parseDateSuggestions(dynamic value) {
  if (value is! List) {
    return const <MatiDateSuggestion>[];
  }

  final suggestions = <MatiDateSuggestion>[];
  for (final item in value) {
    final mapItem = _asStringDynamicMap(item);
    if (mapItem.isNotEmpty) {
      suggestions.add(MatiDateSuggestion.fromJson(mapItem));
    }
  }
  return suggestions;
}
