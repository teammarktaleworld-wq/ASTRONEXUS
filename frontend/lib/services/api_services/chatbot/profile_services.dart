import "dart:convert";
import "dart:io";

import "package:astro_tale/helper/chart_cache_helper.dart";
import "package:astro_tale/services/API/APIservice.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class ProfileService {
  const ProfileService._();

  static Future<void> fetchMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null || token.isEmpty) {
      throw Exception("Auth token missing");
    }

    final response = await http.get(
      Uri.parse("$baseurl/user/me"),
      headers: <String, String>{
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch profile: ${response.statusCode}");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = _extractUser(data);

    await prefs.setString("userName", user["name"]?.toString() ?? "Guest");
    await prefs.setString("email", user["email"]?.toString() ?? "");
    await prefs.setString("phone", user["phone"]?.toString() ?? "");
    await prefs.setString(
      "userId",
      user["id"]?.toString() ?? user["_id"]?.toString() ?? "",
    );
    await prefs.setString("sessionId", user["sessionId"]?.toString() ?? "");
    await prefs.setString("role", user["role"]?.toString() ?? "");

    await prefs.setString(
      "userAvatar",
      _resolveAvatarUrl(user["profileImage"]),
    );

    final astrology =
        (user["astrologyProfile"] ?? <String, dynamic>{})
            as Map<String, dynamic>;
    final zodiac =
        (astrology["rashi"] ?? astrology["zodiacSign"] ?? astrology["zodiac"])
            ?.toString()
            .trim();
    if (zodiac != null && zodiac.isNotEmpty) {
      await prefs.setString("zodiacSign", zodiac);
      await prefs.setString("vedic_rashi", zodiac.toLowerCase());
    }
    await prefs.setString(
      "birthDate",
      astrology["dateOfBirth"]?.toString() ?? "",
    );
    await prefs.setString(
      "birthTime",
      astrology["timeOfBirth"]?.toString() ?? "",
    );
    await prefs.setString(
      "birthPlace",
      astrology["placeOfBirth"]?.toString() ?? "",
    );

    final charts = (user["charts"] as List<dynamic>? ?? <dynamic>[]);
    final latestChart = _pickLatestChart(charts);
    if (latestChart != null) {
      await _storeLatestChartData(prefs, latestChart, charts);
    }
  }

  static Map<String, dynamic> _extractUser(Map<String, dynamic> payload) {
    final topUser = _asMap(payload["user"]);
    if (topUser.isNotEmpty) {
      return topUser;
    }

    final data = _asMap(payload["data"]);
    final nestedUser = _asMap(data["user"]);
    if (nestedUser.isNotEmpty) {
      return nestedUser;
    }

    if (data.containsKey("email") || data.containsKey("name")) {
      return data;
    }
    return <String, dynamic>{};
  }

  static String _resolveAvatarUrl(dynamic profileImage) {
    if (profileImage is! Map<String, dynamic>) {
      return "";
    }
    if (profileImage["url"] != null) {
      return _normalizeAvatarUrl(profileImage["url"].toString());
    }
    if (profileImage["publicId"] != null) {
      return _normalizeAvatarUrl(
        "https://res.cloudinary.com/dgad4eoty/image/upload/${profileImage["publicId"]}",
      );
    }
    return "";
  }

  static Future<void> _storeLatestChartData(
    SharedPreferences prefs,
    Map<String, dynamic> latestChart,
    List<dynamic> allCharts,
  ) async {
    final chartData = _asMap(latestChart["chartData"]);
    final chartImage =
        latestChart["chartImage"]?.toString() ??
        latestChart["chartImageUrl"]?.toString();

    await ChartCacheHelper.cacheChart(
      chartData: chartData,
      chartImage: chartImage,
      allCharts: allCharts,
      fallbackRashi: latestChart["rashi"]?.toString(),
    );

    await prefs.setString("allCharts", jsonEncode(allCharts));
  }

  static Map<String, dynamic>? _pickLatestChart(List<dynamic> charts) {
    if (charts.isEmpty) {
      return null;
    }

    final parsed = charts
        .map(_asMap)
        .where((chart) => chart.isNotEmpty)
        .toList(growable: false);
    if (parsed.isEmpty) {
      return null;
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

  static Future<String?> uploadProfileImage(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null || token.isEmpty) {
      throw Exception("Auth token missing");
    }

    const fieldCandidates = <String>["profileImg", "profileImage", "image"];
    http.Response? lastResponse;

    for (final fieldName in fieldCandidates) {
      final response = await _uploadWithFieldName(
        token: token,
        image: image,
        fieldName: fieldName,
      );
      lastResponse = response;

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (response.statusCode == 401 || response.statusCode == 403) {
          break;
        }
        continue;
      }

      try {
        final payload = jsonDecode(response.body);
        if (payload is Map<String, dynamic>) {
          final fromPayload = _extractAvatarFromPayload(payload);
          if (fromPayload.isNotEmpty) {
            await prefs.setString("userAvatar", fromPayload);
            return fromPayload;
          }
        }
      } catch (_) {
        // Fall through and try refreshing canonical profile data.
      }

      try {
        await fetchMyProfile();
        final refreshed = (prefs.getString("userAvatar") ?? "").trim();
        if (refreshed.isNotEmpty) {
          return refreshed;
        }
      } catch (_) {
        // ignore and continue
      }
      // Upload succeeded but avatar URL was not discoverable; try next field name.
      continue;
    }

    if (lastResponse != null) {
      debugPrint(
        "Profile image upload failed: ${lastResponse.statusCode} ${lastResponse.body}",
      );
    }
    throw Exception("Image upload failed");
  }

  static Future<http.Response> _uploadWithFieldName({
    required String token,
    required File image,
    required String fieldName,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseurl/user/profile-image"),
    );
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath(fieldName, image.path));
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  static String _extractAvatarFromPayload(Map<String, dynamic> payload) {
    final data = _asMap(payload["data"]);
    final user = _asMap(payload["user"]);
    final dataUser = _asMap(data["user"]);

    final roots = <Map<String, dynamic>>[payload, data, user, dataUser];

    for (final root in roots) {
      final profileImage = _asMap(root["profileImage"]);
      final url = _normalizeAvatarUrl(profileImage["url"]?.toString() ?? "");
      if (url.isNotEmpty) {
        return url;
      }

      final publicId = profileImage["publicId"]?.toString() ?? "";
      if (publicId.isNotEmpty) {
        return _normalizeAvatarUrl(
          "https://res.cloudinary.com/dgad4eoty/image/upload/$publicId",
        );
      }

      final avatarUrl = _normalizeAvatarUrl(
        root["avatar"]?.toString() ?? root["avatarUrl"]?.toString() ?? "",
      );
      if (avatarUrl.isNotEmpty) {
        return avatarUrl;
      }
    }

    final payloadUrl = _normalizeAvatarUrl(
      payload["url"]?.toString() ?? payload["imageUrl"]?.toString() ?? "",
    );
    if (payloadUrl.isNotEmpty) {
      return payloadUrl;
    }
    return "";
  }

  static String _normalizeAvatarUrl(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) {
      return "";
    }
    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }
    if (value.startsWith("//")) {
      return "https:$value";
    }
    if (value.startsWith("/")) {
      return "$baseurl$value";
    }
    return "$baseurl/$value";
  }
}
