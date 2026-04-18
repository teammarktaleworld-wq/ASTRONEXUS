import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../subscription/views/subscription_screen.dart';

class ServiceData {
  final String title;
  final String description;
  final String asset;
  final Color color;
  final VoidCallback onTap;

  ServiceData({
    required this.title,
    required this.description,
    required this.asset,
    required this.color,
    required this.onTap,
  });
}

class ServiceCard extends StatelessWidget {
  final ServiceData data;
  final bool isPremium;

  const ServiceCard({required this.data, this.isPremium = false, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : AppColors.lightContainer;
    final titleColor = Colors.white;
    final subtitleColor = Colors.white70;

    return InkWell(
      onTap: () {
        if (isPremium) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SubscriptionPage()),
          );
        } else {
          data.onTap();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: cardColor,
          border: Border.all(color: data.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.32 : 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Icon container with gradient
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        data.color.withOpacity(0.25),
                        data.color.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(data.asset, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.title,
                        style: GoogleFonts.dmSans(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.description,
                        style: GoogleFonts.dmSans(
                          color: subtitleColor,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Premium lock
            if (isPremium)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
