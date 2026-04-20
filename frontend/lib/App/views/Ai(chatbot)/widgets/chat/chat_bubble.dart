import "package:astro_tale/core/constants/app_colors.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? userAvatar;
  final String? botAvatar;
  final List<String> keywords;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.userAvatar,
    this.botAvatar,
    this.keywords = const <String>[],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    final textColor = isUser
        ? Colors.white
        : (isDark
              ? Colors.white.withValues(alpha: 0.92)
              : const Color(0xFF0F172A));
    final botBubbleColor = isDark
        ? AppColors.surfaceAlt
        : Colors.white.withValues(alpha: 0.96);
    final userGradient = const LinearGradient(
      colors: <Color>[Color(0xFF2B6CB0), Color(0xFF1E3A8A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    TextSpan buildSpan() {
      if (keywords.isEmpty) {
        return TextSpan(
          text: text,
          style: GoogleFonts.dmSans(
            color: textColor,
            fontSize: 15,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        );
      }

      final spans = <TextSpan>[];
      String remaining = text;

      while (remaining.isNotEmpty) {
        int index = remaining.length;
        String? matchedKeyword;

        for (final keyword in keywords) {
          final current = remaining.toLowerCase().indexOf(
            keyword.toLowerCase(),
          );
          if (current >= 0 && current < index) {
            index = current;
            matchedKeyword = remaining.substring(
              current,
              current + keyword.length,
            );
          }
        }

        if (index > 0) {
          spans.add(
            TextSpan(
              text: remaining.substring(0, index),
              style: GoogleFonts.dmSans(
                color: textColor,
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (matchedKeyword != null) {
          spans.add(
            TextSpan(
              text: matchedKeyword,
              style: GoogleFonts.dmSans(
                color: isUser
                    ? const Color(0xFFFCD34D)
                    : AppColors.lightPrimary,
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
          remaining = remaining.substring(index + matchedKeyword.length);
        } else {
          break;
        }
      }

      return TextSpan(children: spans);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!isUser) ...<Widget>[
            CircleAvatar(
              radius: 19,
              backgroundColor: isDark
                  ? const Color(0xFF24314E)
                  : const Color(0xFFEAF2FF),
              backgroundImage: botAvatar != null
                  ? AssetImage(botAvatar!)
                  : null,
              child: botAvatar == null
                  ? const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Color(0xFF2563EB),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: isUser
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                  : const EdgeInsets.fromLTRB(14, 12, 14, 16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? userGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF2B2E4A).withOpacity(0.92),
                                const Color(0xFF23264A).withOpacity(0.98),
                              ]
                            : [
                                Colors.white.withOpacity(0.98),
                                const Color(0xFFF3F7FF).withOpacity(0.98),
                              ],
                      ),
                color: isUser ? null : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 7),
                  bottomRight: Radius.circular(isUser ? 7 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : (isDark ? Colors.white24 : const Color(0xFFD8E3F6)),
                  width: 1.2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3B3F5C).withOpacity(0.7)
                                : const Color(0xFF7C3AED).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 15,
                                color: Color(0xFFDBC33F),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Mati Prediction",
                                style: GoogleFonts.dmSans(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.92)
                                      : const Color(0xFF2B2E4A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.2,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.auto_graph_rounded,
                          size: 17,
                          color: isDark
                              ? const Color(0xFFDBC33F)
                              : const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  RichText(text: buildSpan()),
                ],
              ),
            ),
          ),
          if (isUser) ...<Widget>[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 19,
              backgroundColor: isDark
                  ? Colors.white12
                  : const Color(0xFFEAF2FF),
              backgroundImage: userAvatar != null
                  ? NetworkImage(userAvatar!)
                  : null,
              child: userAvatar == null
                  ? const Icon(Icons.person, size: 16, color: Color(0xFF2563EB))
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
