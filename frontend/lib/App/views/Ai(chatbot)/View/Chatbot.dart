import "dart:async";
import "dart:math";

import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/core/widgets/animated_app_background.dart";
import "package:astro_tale/core/widgets/unified_dark_ui.dart";
import "package:astro_tale/services/api_services/chatbot/chat_bot_services.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shimmer/shimmer.dart";

import "../helper/chat_suggestion.dart";
import "../widgets/chat/chat_bubble.dart";
import "../widgets/suggestion_chip.dart";

class MatiChatBotScreen extends StatefulWidget {
  final double bottomNavInset;

  const MatiChatBotScreen({super.key, this.bottomNavInset = 0});

  @override
  State<MatiChatBotScreen> createState() => _MatiChatBotScreenState();
}

class _MatiChatBotScreenState extends State<MatiChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  List<String> suggestions = <String>[];
  List<_ChatMessage> messages = <_ChatMessage>[];
  bool isTyping = false;
  bool isComposing = false;

  late final AnimationController planetController;

  @override
  void initState() {
    super.initState();

    planetController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    controller.addListener(_onComposerTextChanged);

    suggestions = ChatSuggestions.getInitialSuggestions();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      addBotMessage(
        "Namaste! I am Mati, your Vedic astrology guide. Ask me about career, love, or birth chart.",
      );
    });
  }

  @override
  void dispose() {
    planetController.dispose();
    controller.removeListener(_onComposerTextChanged);
    controller.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onComposerTextChanged() {
    final hasInput = controller.text.trim().isNotEmpty;
    if (hasInput == isComposing) {
      return;
    }
    setState(() => isComposing = hasInput);
  }

  void addBotMessage(String text) {
    setState(() => messages.add(_ChatMessage.bot(text: text)));
    scrollDown();
  }

  void addBotInsightMessage(MatiChatResponse response) {
    final answer = response.answer.isEmpty
        ? "I received your message and generated an insight."
        : response.answer;
    setState(
      () => messages.add(_ChatMessage.bot(text: answer, response: response)),
    );
    scrollDown();
  }

  void addUserMessage(String text) {
    setState(() => messages.add(_ChatMessage.user(text)));
    scrollDown();
  }

  Future<void> sendMessage([String? suggestionText]) async {
    if (isTyping) {
      return;
    }

    final text = suggestionText ?? controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    controller.clear();
    focusNode.requestFocus();
    addUserMessage(text);

    setState(() {
      suggestions = ChatSuggestions.getSuggestionsFromQuestion(text);
      isTyping = true;
    });

    try {
      final reply = await ChatbotService.askQuestion(text);
      if (reply.hasRichData) {
        addBotInsightMessage(reply);
      } else {
        addBotMessage(reply.answer);
      }
    } catch (_) {
      addBotMessage(
        "Cosmic signals are weak right now. Please try again shortly.",
      );
    }

    if (mounted) {
      setState(() => isTyping = false);
    }
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final navInset = widget.bottomNavInset < 0 ? 0.0 : widget.bottomNavInset;
    final floatingBottomInset = keyboardInset > 0
        ? 10.0
        : (navInset + safeBottom + 8.0);
    final hasSuggestions = suggestions.isNotEmpty;
    final listBottomPadding =
        (hasSuggestions ? 158.0 : 98.0) + floatingBottomInset;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(context, title: "Mati AI"),
      body: AnimatedAppBackground(
        child: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: planetController,
              builder: (_, __) => _planetField(),
            ),
            Column(
              children: <Widget>[Expanded(child: _chatList(listBottomPadding))],
            ),
            _floatingComposer(
              bottomInset: floatingBottomInset,
              showSuggestions: hasSuggestions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingComposer({
    required double bottomInset,
    required bool showSuggestions,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 10,
      right: 10,
      bottom: bottomInset,
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 10, 2, 2),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0E1731).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? Colors.white24 : const Color(0xFFD6E1F5),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showSuggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SuggestionChips(
                  suggestions: suggestions,
                  isTyping: isTyping || isComposing,
                  onTap: (text) => sendMessage(text),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: _inputBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatList(double bottomPadding) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const TypingIndicatorBubble();
        }
        final msg = messages[index];
        Widget bubble;
        if (msg.isUser) {
          bubble = ChatBubble(
            text: msg.text,
            isUser: true,
            userAvatar: null,
            botAvatar: "assets/images/mati.png",
          );
        } else if (msg.response != null && msg.response!.hasRichData) {
          bubble = _MatiInsightBubble(
            response: msg.response!,
            fallback: msg.text,
          );
        } else {
          bubble = ChatBubble(
            text: msg.text,
            isUser: false,
            userAvatar: null,
            botAvatar: "assets/images/mati.png",
          );
        }
        return _MessageInAnimation(
          key: ValueKey<int>(msg.id),
          delay: Duration(milliseconds: min(index * 38, 180)),
          child: bubble,
        );
      },
    );
  }

  Widget _inputBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark
        ? const Color(0xFF1B2241).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD4E1F8);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark
        ? Colors.white60
        : const Color(0xFF64748B).withValues(alpha: 0.9);
    const sendGradient = <Color>[Color(0xFF22C55E), Color(0xFF16A34A)];
    final sendIconColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.26)
                : const Color(0xFF94A3B8).withValues(alpha: 0.22),
            blurRadius: isDark ? 12 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => sendMessage(),
              minLines: 1,
              maxLines: 4,
              style: GoogleFonts.dmSans(color: textColor),
              decoration: InputDecoration(
                hintText: "Ask about your destiny...",
                hintStyle: TextStyle(color: hintColor),
                border: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sendGradient),
              ),
              child: Icon(LucideIcons.send, size: 18, color: sendIconColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planetField() {
    final t = planetController.value * 2 * pi;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: <Widget>[
        Positioned(
          top: 100 + sin(t) * 40,
          right: -50,
          child: Image.asset(
            "assets/planets/planet1.png",
            height: 140,
            opacity: AlwaysStoppedAnimation(isDark ? 0.45 : 0.26),
          ),
        ),
        Positioned(
          bottom: 120 + cos(t) * 30,
          left: -40,
          child: Image.asset(
            "assets/planets/planet2.png",
            height: 110,
            opacity: AlwaysStoppedAnimation(isDark ? 0.3 : 0.16),
          ),
        ),
      ],
    );
  }
}

class TypingIndicatorBubble extends StatelessWidget {
  const TypingIndicatorBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isDark
        ? AppColors.surfaceAlt
        : Colors.white.withValues(alpha: 0.95);
    final textColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: isDark
                ? const Color(0xFF24314E)
                : const Color(0xFFEFF5FF),
            child: Icon(
              Icons.auto_awesome,
              size: 14,
              color: isDark ? const Color(0xFFFCD34D) : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white24 : const Color(0xFFDCE4F6),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: isDark ? Colors.white12 : const Color(0xFFE5ECFA),
              highlightColor: isDark ? Colors.white24 : Colors.white,
              child: Text(
                "Mati is reading your stars...",
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage.user(this.text) : id = _idSeed++, isUser = true, response = null;

  _ChatMessage.bot({required this.text, this.response})
    : id = _idSeed++,
      isUser = false;

  static int _idSeed = 0;
  final int id;
  final String text;
  final bool isUser;
  final MatiChatResponse? response;
}

class _MessageInAnimation extends StatefulWidget {
  const _MessageInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<_MessageInAnimation> createState() => _MessageInAnimationState();
}

class _MessageInAnimationState extends State<_MessageInAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _MatiInsightBubble extends StatelessWidget {
  const _MatiInsightBubble({required this.response, required this.fallback});

  final MatiChatResponse response;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardGradient = isDark
        ? <Color>[
            const Color(0xFF1A2344).withValues(alpha: 0.95),
            const Color(0xFF101A35).withValues(alpha: 0.96),
          ]
        : <Color>[
            Colors.white.withValues(alpha: 0.98),
            const Color(0xFFF5FAFF).withValues(alpha: 0.98),
          ];
    final borderColor = isDark ? Colors.white24 : const Color(0xFFDCE5F7);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final accent = isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 19,
            backgroundColor: isDark
                ? const Color(0xFF24314E)
                : const Color(0xFFEEF2FF),
            backgroundImage: const AssetImage("assets/images/mati.png"),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: cardGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.24)
                        : const Color(0xFF94A3B8).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _InsightHeader(response: response),
                      const Spacer(),
                      Icon(Icons.query_stats_rounded, size: 18, color: accent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    key: ValueKey<String>(
                      "answer-${response.answer.isEmpty ? fallback : response.answer}",
                    ),
                    duration: const Duration(milliseconds: 360),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 8),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      response.answer.isEmpty ? fallback : response.answer,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.5,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                  ),
                  if (response.analysis != null) ...<Widget>[
                    const SizedBox(height: 10),
                    _InsightMetricStrip(analysis: response.analysis!),
                  ],
                  if (response.analysis != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _AnalysisChart(analysis: response.analysis!),
                  ],
                  if (response.uiMetadata != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _VerdictCard(uiMetadata: response.uiMetadata!),
                  ],
                  if (response.shopSuggestions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    _ShopSuggestionList(
                      suggestions: response.shopSuggestions.take(2).toList(),
                    ),
                  ],
                  if (response.service.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      "Source: ${response.service}",
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: bodyColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightMetricStrip extends StatelessWidget {
  const _InsightMetricStrip({required this.analysis});

  final MatiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final score = _percent(analysis.decisionScore);
    final positive = _percent(analysis.positivePercentage);
    final negative = _percent(analysis.negativePercentage);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF1F7FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFDDE7F8),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _MetricPill(
            icon: Icons.insights_rounded,
            label: "Score",
            value: "${score.toStringAsFixed(0)}%",
            color: const Color(0xFF16A34A),
          ),
          _MetricPill(
            icon: Icons.trending_up_rounded,
            label: "Positive",
            value: "${positive.toStringAsFixed(0)}%",
            color: const Color(0xFF22C55E),
          ),
          _MetricPill(
            icon: Icons.trending_down_rounded,
            label: "Negative",
            value: "${negative.toStringAsFixed(0)}%",
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            "$label $value",
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightHeader extends StatelessWidget {
  const _InsightHeader({required this.response});

  final MatiChatResponse response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white12 : const Color(0xFFF1F5FF);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final type = response.uiMetadata?.type ?? "";
    final typeLabel = type.isEmpty
        ? "Insight"
        : "${type[0].toUpperCase()}${type.substring(1)}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF2563EB),
          ),
          const SizedBox(width: 6),
          Text(
            "Mati $typeLabel",
            style: GoogleFonts.dmSans(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisChart extends StatelessWidget {
  const _AnalysisChart({required this.analysis});

  final MatiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white10 : const Color(0xFFF8FAFF);
    final score = _percent(analysis.decisionScore);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Cosmic Score",
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _ScoreRing(score: score),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: <Widget>[
                    _PercentTrack(
                      label: "Positive",
                      value: _percent(analysis.positivePercentage),
                      color: const Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 8),
                    _PercentTrack(
                      label: "Negative",
                      value: _percent(analysis.negativePercentage),
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (analysis.planetBreakdown.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              "Planet Impact",
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            ...analysis.planetBreakdown
                .take(4)
                .map(
                  (planet) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                planet.planet,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            Text(
                              "${planet.strength.toStringAsFixed(0)}/10",
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: bodyColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (planet.strength / 10)
                                .clamp(0, 1)
                                .toDouble(),
                            minHeight: 6,
                            backgroundColor: isDark
                                ? Colors.white12
                                : const Color(0xFFE5EAF8),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              planet.isPositive
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        if (planet.reason.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            planet.reason,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: bodyColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = score >= 70
        ? const Color(0xFF22C55E)
        : (score >= 45 ? const Color(0xFFEAB308) : const Color(0xFFEF4444));

    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 7,
            backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              "${score.toStringAsFixed(0)}%",
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentTrack extends StatelessWidget {
  const _PercentTrack({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const Spacer(),
            Text(
              "${value.toStringAsFixed(0)}%",
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: isDark ? Colors.white12 : const Color(0xFFE5EAF8),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.uiMetadata});

  final MatiUiMetadata uiMetadata;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = _parseHexColor(
      uiMetadata.color,
      fallback: isDark ? const Color(0xFF84CC16) : const Color(0xFF2563EB),
    );
    final bgColor = isDark ? Colors.white10 : const Color(0xFFF8FAFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  uiMetadata.verdict.isEmpty ? "Verdict" : uiMetadata.verdict,
                  style: GoogleFonts.dmSans(
                    color: borderColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (uiMetadata.action.isNotEmpty)
                Text(
                  uiMetadata.action,
                  style: GoogleFonts.dmSans(
                    color: bodyColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (uiMetadata.summary.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              uiMetadata.summary,
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShopSuggestionList extends StatelessWidget {
  const _ShopSuggestionList({required this.suggestions});

  final List<MatiShopSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white10 : const Color(0xFFF8FAFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Recommended Remedies",
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map(
          (item) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFDCE4F5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.name.isEmpty ? "Product" : item.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ),
                    if (item.price > 0)
                      Text(
                        "${item.currency} ${item.price.toStringAsFixed(0)}",
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
                      ),
                  ],
                ),
                if (item.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: bodyColor,
                      height: 1.35,
                    ),
                  ),
                ],
                if (item.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFE6EEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.dmSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: bodyColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

double _percent(double value) {
  return value.clamp(0, 100).toDouble();
}

Color _parseHexColor(String raw, {required Color fallback}) {
  final hex = raw.trim().replaceAll("#", "");
  if (hex.isEmpty) {
    return fallback;
  }
  final normalized = hex.length == 6 ? "FF$hex" : hex;
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) {
    return fallback;
  }
  return Color(parsed);
}
