import "package:flutter/material.dart";
import "package:flutter_skeleton_ui/flutter_skeleton_ui.dart";
import "package:google_fonts/google_fonts.dart";

import "package:astro_tale/App/Model/notification_model.dart";
import "../../../../services/api_services/notification_service.dart";
import "../widgets/notification_card.dart";

class NotificationScreen extends StatefulWidget {
  final String token;

  const NotificationScreen({super.key, required this.token});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationService _service;
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _service = NotificationService(token: widget.token);
    _notificationsFuture = _service.getNotifications();
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      setState(() {
        _notificationsFuture = _service.getNotifications();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update notification: $e")),
      );
    }
  }

  Future<void> _refreshNotifications() async {
    final next = _service.getNotifications();
    setState(() => _notificationsFuture = next);
    await next;
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  Widget _notificationShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.9);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: tileColor,
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFD8E3F6),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: SkeletonItem(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 44,
                  width: 44,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 14,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.55,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final bgGradient = isDark
        ? const <Color>[Color(0xFF050B1E), Color(0xFF1B2744), Color(0xFF050B1E)]
        : const <Color>[
            Color(0xFFF6FAFF),
            Color(0xFFE8F1FF),
            Color(0xFFF6FAFF),
          ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: titleColor,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bgGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          FutureBuilder<List<NotificationModel>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _notificationShimmer();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: GoogleFonts.poppins(color: titleColor),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "No notifications",
                    style: GoogleFonts.poppins(color: subtitleColor),
                  ),
                );
              }

              final notifications = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationCard(
                        title: n.title,
                        message: n.message,
                        time: _formatTime(n.createdAt),
                        type: n.type,
                        isUnread: !n.read,
                        onTap: () => _markAsRead(n.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
