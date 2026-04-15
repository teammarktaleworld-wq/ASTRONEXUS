import 'dart:convert';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'] ?? 'system',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'message': message,
    'type': type,
    'read': read,
    'createdAt': createdAt.toIso8601String(),
  };

  static List<NotificationModel> listFromJson(String jsonString) {
    final List data = json.decode(jsonString);
    return data.map((n) => NotificationModel.fromJson(n)).toList();
  }
}
