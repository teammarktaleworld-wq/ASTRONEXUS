import "package:astro_tale/core/localization/app_localizations.dart";
import "package:astro_tale/ui_componets/cosmic/cosmic_one.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const <Color>[
                        Color(0xff050B1E),
                        Color(0xff393053),
                        Color(0xff050B1E),
                      ]
                    : const <Color>[
                        Color(0xFFF7FAFF),
                        Color(0xFFEAF1FF),
                        Color(0xFFF7FAFF),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (isDark) const Positioned.fill(child: SmoothShootingStars()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tr("subscriptionHint"),
                    style: GoogleFonts.dmSans(
                      color: isDark
                          ? Colors.white70
                          : colors.onSurface.withOpacity(0.72),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _promoBanner(context),
                  const SizedBox(height: 24),
                  Text(
                    l10n.tr("subscriptionPlans"),
                    style: GoogleFonts.dmSans(
                      color: isDark ? Colors.white : colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ModernPlanCard(
                          title: "Weekly",
                          price: "₹199",
                          tagline: "Gentle start for guidance",
                          features: const [
                            "Daily Horoscope",
                            "Basic Insights",
                            "Priority reminders",
                          ],
                        ),
                        const SizedBox(height: 14),
                        ModernPlanCard(
                          title: "Monthly",
                          price: "₹699",
                          tagline: "Complete astrological support",
                          highlight: true,
                          features: const [
                            "Daily Horoscope",
                            "Nutritional Astrology",
                            "Exclusive Videos",
                            "Chat Support",
                          ],
                        ),
                        const SizedBox(height: 14),
                        ModernPlanCard(
                          title: "Yearly",
                          price: "₹6,999",
                          tagline: "Deep long-term guidance",
                          features: const [
                            "All Monthly Features",
                            "Priority Astrologer Support",
                            "Premium Content",
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.tr("upgradeJourney"),
            style: GoogleFonts.dmSans(
              color: isDark ? Colors.white : colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white70 : colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _promoBanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? const <Color>[Color(0xFF2E3F8D), Color(0xFF5C45A0)]
              : <Color>[
                  colors.primary.withOpacity(0.88),
                  colors.secondary.withOpacity(0.82),
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -14,
            child: Icon(Icons.auto_awesome, size: 120, color: Colors.white12),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Premium Cosmic Access",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Unlock complete reports and priority support.",
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModernPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String tagline;
  final List<String> features;
  final bool highlight;

  const ModernPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.tagline,
    required this.features,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final border = highlight
        ? colors.primary.withOpacity(0.8)
        : (isDark ? Colors.white12 : colors.outline.withOpacity(0.3));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colors.surface.withOpacity(isDark ? 0.82 : 0.96),
        border: Border.all(color: border, width: highlight ? 1.3 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : colors.onSurface,
                  ),
                ),
              ),
              if (highlight)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    context.l10n.tr("new"),
                    style: GoogleFonts.dmSans(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            tagline,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withOpacity(0.72)
                  : colors.onSurface.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            price,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        color: isDark
                            ? Colors.white.withOpacity(0.88)
                            : colors.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: Text(
                context.l10n.tr("subscribe"),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
