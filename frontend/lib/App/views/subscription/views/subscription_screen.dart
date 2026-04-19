import "package:astro_tale/core/localization/app_localizations.dart";
import "package:astro_tale/core/constants/app_colors.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class _PlanData {
  final String title;
  final String price;
  final String tagline;
  final List<String> features;
  final bool highlight;

  const _PlanData({
    required this.title,
    required this.price,
    required this.tagline,
    required this.features,
    this.highlight = false,
  });
}

const List<_PlanData> _plans = <_PlanData>[
  _PlanData(
    title: "Weekly",
    price: "₹199",
    tagline: "Gentle start for guidance",
    features: <String>[
      "Daily Horoscope",
      "Basic Insights",
      "Priority reminders",
    ],
  ),
  _PlanData(
    title: "Monthly",
    price: "₹699",
    tagline: "Complete astrological support",
    highlight: true,
    features: <String>[
      "Daily Horoscope",
      "Nutritional Astrology",
      "Exclusive Videos",
      "Chat Support",
    ],
  ),
  _PlanData(
    title: "Yearly",
    price: "₹6,999",
    tagline: "Deep long-term guidance",
    features: <String>[
      "All Monthly Features",
      "Priority Astrologer Support",
      "Premium Content",
    ],
  ),
];

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(color: isDark ? AppColors.background : colors.surface),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 420;
                final bool wide = constraints.maxWidth >= 700;
                final double maxContentWidth = constraints.maxWidth < 980
                    ? 720
                    : 920;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 16 : 24,
                        vertical: 10,
                      ),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _header(context)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                l10n.tr("subscriptionHint"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  color: isDark
                                      ? Colors.white70
                                      : colors.onSurface.withValues(
                                          alpha: 0.72,
                                        ),
                                  fontSize: compact ? 13 : 14,
                                  height: 1.55,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: _promoBanner(context),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                l10n.tr("subscriptionPlans"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  color: isDark
                                      ? Colors.white
                                      : colors.onSurface,
                                  fontSize: compact ? 17 : 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 14, bottom: 24),
                            sliver: wide
                                ? SliverGrid.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 14,
                                          crossAxisSpacing: 14,
                                          childAspectRatio: 0.86,
                                        ),
                                    itemCount: _plans.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final plan = _plans[index];
                                          return ModernPlanCard(
                                            title: plan.title,
                                            price: plan.price,
                                            tagline: plan.tagline,
                                            features: plan.features,
                                            highlight: plan.highlight,
                                          );
                                        },
                                  )
                                : SliverList.separated(
                                    itemCount: _plans.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final plan = _plans[index];
                                          return ModernPlanCard(
                                            title: plan.title,
                                            price: plan.price,
                                            tagline: plan.tagline,
                                            features: plan.features,
                                            highlight: plan.highlight,
                                          );
                                        },
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: "Close",
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white70 : colors.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52),
          child: Text(
            context.l10n.tr("upgradeJourney"),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: isDark ? Colors.white : colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
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
      height: 142,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? const <Color>[Color(0xFF2E3F8D), Color(0xFF5C45A0)]
              : <Color>[
                  colors.primary.withValues(alpha: 0.88),
                  colors.secondary.withValues(alpha: 0.82),
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -16,
            child: Icon(
              Icons.auto_awesome,
              size: 130,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -26,
            child: Icon(
              Icons.brightness_2,
              size: 76,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Premium Cosmic Access",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Unlock complete reports and priority support.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.9),
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
        ? colors.primary.withValues(alpha: 0.8)
        : (isDark ? Colors.white12 : colors.outline.withValues(alpha: 0.3));

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colors.surface.withValues(alpha: isDark ? 0.82 : 0.96),
        border: Border.all(color: border, width: highlight ? 1.3 : 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              opacity: highlight ? 1 : 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.18),
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
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tagline,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : colors.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            price,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 40,
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
                            ? Colors.white.withValues(alpha: 0.88)
                            : colors.onSurface.withValues(alpha: 0.9),
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
                backgroundColor: highlight
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.9),
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
