import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernTarotCard extends StatelessWidget {
  final String title;
  final String description;
  final int position;
  final String imagePath;

  const ModernTarotCard({
    super.key,
    required this.title,
    required this.description,
    required this.position,
    required this.imagePath,
  });

  void _showFullMeaning(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TarotDetailSheet(
        title: title,
        description: description,
        image: imagePath,
        position: position,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final accentColor = isDark
        ? const Color(0xFFD4AF37)
        : theme.colorScheme.primary;
    final cardGradient = isDark
        ? const <Color>[Color(0xFF1E1B2E), Color(0xFF141225)]
        : const <Color>[Color(0xFFFFFFFF), Color(0xFFF1F5FF)];

    return GestureDetector(
      onTap: () => _showFullMeaning(context),
      child: Container(
        width: 220,
        height: 340,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            /// Position badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$position",
                  style: GoogleFonts.dmSans(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Big tarot icon
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x33D4AF37), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: bodyColor,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),

            const Spacer(),

            Text(
              "Tap to reveal",
              style: GoogleFonts.dmSans(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarotDetailSheet extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final int position;

  const _TarotDetailSheet({
    required this.title,
    required this.description,
    required this.image,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final accentColor = isDark
        ? const Color(0xFFD4AF37)
        : theme.colorScheme.primary;
    final sheetGradient = isDark
        ? const <Color>[Color(0xFF141225), Color(0xFF1E1B2E)]
        : const <Color>[Color(0xFFFFFFFF), Color(0xFFF1F5FF)];
    final handleColor = isDark ? Colors.white24 : const Color(0xFFCBD5E1);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: sheetGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Card $position",
                    style: GoogleFonts.dmSans(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      image,
                      height: size.height * 0.45,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: titleColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: bodyColor,
                      height: 1.8,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
