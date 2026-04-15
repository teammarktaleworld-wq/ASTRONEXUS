import 'dart:math';

import 'package:astro_tale/App/Model/tarot_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../services/api_services/tarot_api.dart';
import '../pdf/tarot_pdf.dart';
import '../widgets/modern_action_button.dart';
import '../widgets/modern_tarot_card.dart';
import '../../../../ui_componets/cosmic/cosmic_one.dart';

class TarotResult extends StatefulWidget {
  final String name;
  final String spread;
  final int cardCount;

  const TarotResult({
    super.key,
    required this.name,
    required this.spread,
    required this.cardCount,
  });

  @override
  State<TarotResult> createState() => _TarotResultState();
}

class _TarotResultState extends State<TarotResult> {
  late Future<List<TarotCard>> futureCards;
  int selectedTab = 0;

  final List<String> tarotImages = [
    'assets/tarot/tarot_one.png',
    'assets/tarot/tarot_two.png',
    'assets/tarot/tarot_three.png',
    'assets/tarot/tarot_one.png',
  ];

  late List<String> selectedImages;

  @override
  void initState() {
    super.initState();
    futureCards = TarotApi.fetchCards(widget.cardCount);

    final random = Random();
    selectedImages = List.generate(
      widget.cardCount,
      (_) => tarotImages[random.nextInt(tarotImages.length)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final topGradient = isDark
        ? const <Color>[Color(0xff070D26), Color(0xff241A3D), Color(0xff070D26)]
        : const <Color>[
            Color(0xFFF5F7FF),
            Color(0xFFE7EEFF),
            Color(0xFFF8FAFF),
          ];
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final accentColor = isDark ? const Color(0xFFD4AF37) : colors.primary;
    final panelFill = isDark
        ? const Color(0xFF1E2236)
        : Colors.white.withValues(alpha: 0.94);
    final tabFill = isDark
        ? const Color(0xFF1A2036)
        : Colors.white.withValues(alpha: 0.95);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: topGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (isDark) Positioned.fill(child: SmoothShootingStars()),
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: .55)
                  : Colors.white.withValues(alpha: .45),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(titleColor: titleColor, accentColor: accentColor),
                Expanded(
                  child: FutureBuilder<List<TarotCard>>(
                    future: futureCards,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _shimmerLoading(
                          isDark: isDark,
                          titleColor: titleColor,
                        );
                      }

                      if (snapshot.hasError) {
                        return _errorView(
                          snapshot.error,
                          titleColor: titleColor,
                          bodyColor: subtitleColor,
                          accentColor: accentColor,
                          isDark: isDark,
                        );
                      }

                      final cards = snapshot.data ?? const <TarotCard>[];
                      if (cards.isEmpty) {
                        return _errorView(
                          'No tarot cards returned from API.',
                          titleColor: titleColor,
                          bodyColor: subtitleColor,
                          accentColor: accentColor,
                          isDark: isDark,
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _headerSection(
                              cards.length,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            ),
                            const SizedBox(height: 24),
                            _readingToggle(
                              tabFill: tabFill,
                              accentColor: accentColor,
                              activeTextColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                              inactiveTextColor: subtitleColor,
                            ),
                            const SizedBox(height: 26),
                            _cardsSpread(cards),
                            const SizedBox(height: 28),
                            _dynamicInfoPanel(
                              cards,
                              panelFill: panelFill,
                              titleColor: titleColor,
                              accentColor: accentColor,
                              bodyColor: subtitleColor,
                            ),
                            const SizedBox(height: 30),
                            _saveButton(cards),
                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar({required Color titleColor, required Color accentColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: accentColor),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Your Tarot Reading',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(Icons.auto_awesome, color: accentColor),
        ],
      ),
    );
  }

  Widget _headerSection(
    int count, {
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      children: [
        Text(
          'Mystic Guidance',
          style: GoogleFonts.dmSans(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideY(begin: 0.3),
        const SizedBox(height: 6),
        Text(
          'Welcome, ${widget.name} - $count cards',
          style: GoogleFonts.dmSans(color: subtitleColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _readingToggle({
    required Color tabFill,
    required Color accentColor,
    required Color activeTextColor,
    required Color inactiveTextColor,
  }) {
    final tabs = ['Cards', 'Meanings', 'Details'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: tabFill,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: selected ? activeTextColor : inactiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _cardsSpread(List<TarotCard> cards) {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final card = cards[index];
          final imagePath = selectedImages[index % selectedImages.length];
          return ModernTarotCard(
            title: card.name,
            description: card.meaningUp.isEmpty ? card.desc : card.meaningUp,
            position: index + 1,
            imagePath: imagePath,
          ).animate().fadeIn().slideY(begin: 0.2);
        },
      ),
    );
  }

  Widget _dynamicInfoPanel(
    List<TarotCard> cards, {
    required Color panelFill,
    required Color titleColor,
    required Color accentColor,
    required Color bodyColor,
  }) {
    final title = _panelTitle();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == cards.length - 1 ? 0 : 16,
              ),
              child: _cardDetailsBlock(
                index + 1,
                card,
                accentColor: accentColor,
                bodyColor: bodyColor,
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  String _panelTitle() {
    if (selectedTab == 0) {
      return 'Cards Output';
    }
    if (selectedTab == 1) {
      return 'Card Meanings';
    }
    return 'Card Details';
  }

  Widget _cardDetailsBlock(
    int position,
    TarotCard card, {
    required Color accentColor,
    required Color bodyColor,
  }) {
    final headingStyle = GoogleFonts.dmSans(
      color: accentColor,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    final bodyStyle = GoogleFonts.dmSans(
      color: bodyColor,
      height: 1.5,
      fontSize: 13.5,
    );

    if (selectedTab == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card $position: ${card.name}', style: headingStyle),
          const SizedBox(height: 6),
          Text('Type: ${card.type} - Value: ${card.value}', style: bodyStyle),
        ],
      );
    }

    if (selectedTab == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card $position: ${card.name}', style: headingStyle),
          const SizedBox(height: 6),
          Text('Upright: ${_safeText(card.meaningUp)}', style: bodyStyle),
          const SizedBox(height: 6),
          Text('Reversed: ${_safeText(card.meaningRev)}', style: bodyStyle),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card $position: ${card.name}', style: headingStyle),
        const SizedBox(height: 6),
        Text(_safeText(card.desc), style: bodyStyle),
      ],
    );
  }

  String _safeText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'No data from API for this field.' : trimmed;
  }

  Widget _saveButton(List<TarotCard> cards) {
    return ModernActionButton(
      title: 'Save as PDF',
      onTap: () async {
        final pdfCards = cards
            .take(widget.cardCount)
            .map(
              (c) => {
                'title': c.name,
                'description':
                    'Type: ${c.type}\nUpright: ${_safeText(c.meaningUp)}\nReversed: ${_safeText(c.meaningRev)}\nDetail: ${_safeText(c.desc)}',
              },
            )
            .toList();

        await TarotPdfService.generateAndOpenPdf(
          userName: widget.name,
          spread: widget.spread,
          cards: pdfCards,
        );
      },
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _shimmerLoading({required bool isDark, required Color titleColor}) {
    final baseColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? Colors.white24
        : const Color(0xFFFFFFFF).withValues(alpha: 0.95);
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(height: 24, width: 180, color: titleColor),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: titleColor,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: titleColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: titleColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(
    Object? error, {
    required Color titleColor,
    required Color bodyColor,
    required Color accentColor,
    required bool isDark,
  }) {
    final raw = (error?.toString() ?? '').trim();
    final message = raw.isEmpty
        ? 'Unable to load tarot cards. Please try again.'
        : raw;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: accentColor, size: 36),
            const SizedBox(height: 12),
            Text(
              'Tarot API request failed',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: bodyColor),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  futureCards = TarotApi.fetchCards(widget.cardCount);
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
