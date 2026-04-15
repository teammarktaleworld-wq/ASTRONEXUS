import "dart:ui";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String type;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.type = "system",
    this.isUnread = false,
    this.onTap,
  });

  IconData _iconForType() {
    switch (type.toLowerCase()) {
      case "order":
        return Icons.local_shipping_rounded;
      case "payment":
        return Icons.account_balance_wallet_rounded;
      case "offer":
      case "promo":
      case "promotion":
        return Icons.local_offer_rounded;
      case "alert":
      case "warning":
        return Icons.warning_amber_rounded;
      case "reminder":
        return Icons.schedule_rounded;
      case "chat":
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _accentForType(bool isDark) {
    switch (type.toLowerCase()) {
      case "order":
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
      case "payment":
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      case "offer":
      case "promo":
      case "promotion":
        return isDark ? const Color(0xFFFACC15) : const Color(0xFFCA8A04);
      case "alert":
      case "warning":
        return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      case "reminder":
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
      case "chat":
        return isDark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2);
      default:
        return isDark ? const Color(0xFF6EE7F9) : const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadColor = _accentForType(isDark);
    final typeIcon = _iconForType();
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.86);
    final borderColor = isUnread
        ? unreadColor.withValues(alpha: isDark ? 0.8 : 0.55)
        : (isDark ? Colors.white10 : const Color(0xFFD6E1F5));
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final messageColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final timeColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);
    final iconColor = isDark ? Colors.white : const Color(0xFF1E3A8A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cardColor,
            border: Border.all(color: borderColor, width: isUnread ? 1.2 : 1),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: isUnread
                    ? unreadColor.withValues(alpha: isDark ? 0.16 : 0.12)
                    : Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: isUnread ? 10 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnread
                            ? unreadColor.withValues(
                                alpha: isDark ? 0.22 : 0.14,
                              )
                            : (isDark
                                  ? Colors.white12
                                  : const Color(0xFFEAF1FF)),
                      ),
                      child: Icon(
                        isUnread ? typeIcon : Icons.notifications_none_rounded,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              color: titleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: GoogleFonts.poppins(
                              color: messageColor,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: unreadColor.withValues(
                                alpha: isDark ? 0.18 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: unreadColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            time,
                            style: GoogleFonts.poppins(
                              color: timeColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 6, top: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: unreadColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
