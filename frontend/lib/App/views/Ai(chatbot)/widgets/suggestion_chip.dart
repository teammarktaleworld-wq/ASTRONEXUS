import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class SuggestionChips extends StatefulWidget {
  final List<String> suggestions;
  final bool isTyping;
  final Function(String) onTap;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    this.isTyping = false,
    required this.onTap,
  });

  @override
  State<SuggestionChips> createState() => _SuggestionChipsState();
}

class _SuggestionChipsState extends State<SuggestionChips>
    with TickerProviderStateMixin {
  late final AnimationController entryController;
  late final AnimationController driftController;
  late final Animation<double> fadeAnim;
  late final Animation<Offset> slideAnim;
  late final Animation<double> driftAnim;

  @override
  void initState() {
    super.initState();
    entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    driftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: 0.5,
    );

    fadeAnim = CurvedAnimation(parent: entryController, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: entryController, curve: Curves.easeOutCubic),
        );
    driftAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: driftController, curve: Curves.easeInOut),
    );

    entryController.forward();
    _syncTypingMotion();
  }

  @override
  void didUpdateWidget(covariant SuggestionChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.suggestions != oldWidget.suggestions) {
      entryController
        ..reset()
        ..forward();
    }
    if (widget.isTyping != oldWidget.isTyping) {
      _syncTypingMotion();
    }
  }

  void _syncTypingMotion() {
    if (widget.isTyping) {
      if (!driftController.isAnimating) {
        driftController.repeat(reverse: true);
      }
      return;
    }
    driftController
      ..stop()
      ..value = 0.5;
  }

  @override
  void dispose() {
    entryController.dispose();
    driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: driftController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.isTyping ? driftAnim.value : 0, 0),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _SuggestionChip(
                  text: widget.suggestions[index],
                  onTap: widget.onTap,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String text;
  final Function(String) onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapCancel: () => setState(() => isPressed = false),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap(widget.text);
      },
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: isDark
                ? Colors.white.withValues(alpha: isPressed ? 0.16 : 0.1)
                : Colors.white.withValues(alpha: isPressed ? 0.88 : 0.95),
            border: Border.all(
              color: isDark ? Colors.white24 : const Color(0xFFD9E4F7),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF9AAECE).withValues(alpha: 0.24),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.dmSans(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
