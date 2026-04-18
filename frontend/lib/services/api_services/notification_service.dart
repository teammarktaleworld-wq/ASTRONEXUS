import "dart:convert";

import "package:astro_tale/App/Model/notification_model.dart";
import "package:astro_tale/services/API/APIservice.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

class NotificationService {
  final String token;

  NotificationService({required this.token});

  Map<String, String> get _headers => <String, String>{
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  Future<List<NotificationModel>> getNotifications() async {
    final url = Uri.parse("$baseurl/api/notifications");

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      debugPrint(
        "Notifications fetch failed: ${response.statusCode} ${response.body}",
      );
      throw Exception("Failed to load notifications: ${response.statusCode}");
    }

    final dynamic data = jsonDecode(response.body);
    final notifications = data is List
        ? data
        : (data["notifications"] ??
              data["data"] ??
              data["results"] ??
              <dynamic>[]);

    return NotificationModel.listFromJson(jsonEncode(notifications));
  }

  Future<void> markAsRead(String notificationId) async {
    final url = Uri.parse("$baseurl/api/notifications/$notificationId/read");

    final response = await http.put(url, headers: _headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        "Mark-as-read failed: ${response.statusCode} ${response.body}",
      );
      throw Exception(
        "Failed to mark notification as read: ${response.statusCode}",
      );
    }
  }

  Future<NotificationModel> createNotification({
    String? userId,
    required String title,
    required String message,
    String type = "system",
    bool broadcast = false,
  }) async {
    final url = Uri.parse("$baseurl/api/notifications");
    final payload = <String, dynamic>{
      "title": title,
      "message": message,
      "type": type,
      "broadcast": broadcast,
    };
    if (userId != null && userId.isNotEmpty) {
      payload["userId"] = userId;
    }

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        "Create notification failed: ${response.statusCode} ${response.body}",
      );
      throw Exception("Failed to create notification: ${response.statusCode}");
    }

    final dynamic data = jsonDecode(response.body);
    if (data is Map<String, dynamic> && data.containsKey("_id")) {
      return NotificationModel.fromJson(data);
    }

    return NotificationModel(
      id: "",
      title: title,
      message: message,
      type: type,
      read: false,
      createdAt: DateTime.now(),
    );
  }
}
