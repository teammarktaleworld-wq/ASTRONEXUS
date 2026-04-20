import 'package:astro_tale/App/views/Tarot/result/Tarot_result.dart';
import 'package:astro_tale/core/widgets/animated_app_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    countController.text = '3';
  }

  @override
  void dispose() {
    nameController.dispose();
    countController.dispose();
    super.dispose();
  }

  Future<void> _generateTarot() async {
    final name = nameController.text.trim();
    final countRaw = countController.text.trim();
    final count = int.tryParse(countRaw.isEmpty ? '3' : countRaw);

    if (name.isEmpty || count == null || count < 1 || count > 78) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your name and choose 1-78 cards'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TarotResult(name: name, spread: 'Custom', cardCount: count),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBackground = isDark
        ? const Color(0xFF181A2B).withOpacity(0.98)
        : Colors.white.withOpacity(0.98);
    final cardBorder = isDark
        ? const Color(0xFFDBC33F).withOpacity(0.22)
        : const Color(0xFFD7E4F8);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final buttonColor = isDark
        ? const Color(0xFF2B2F4A)
        : const Color(0xFF2563EB);
    final buttonBorderColor = isDark
        ? const Color(0xFFDBC33F)
        : const Color(0xFF7FB1FF);

    return Scaffold(
      appBar: _tarotTopBar(context),
      body: AnimatedAppBackground(
        showStarsInDark: true,
        showStarsInLight: true,
        child: Stack(
          children: [
            if (!isDark) Positioned.fill(child: _lightTarotAura()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 400;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 12 : 24,
                        vertical: isSmall ? 16 : 28,
                      ),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF181A2B),
                                  const Color(0xFF23264A).withOpacity(0.98),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.98),
                                  const Color(0xFFE3E8F7).withOpacity(0.98),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(isSmall ? 18 : 26),
                        border: Border.all(color: cardBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.45)
                                : const Color(0xFF9AADD0).withOpacity(0.13),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Let the Cards Speak',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: titleColor,
                              fontSize: isSmall ? 17 : 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your name and choose how many cards to reveal.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: subtitleColor,
                              fontSize: isSmall ? 12 : 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _inputField(
                            label: 'Your Name',
                            icon: Icons.person_outline,
                            controller: nameController,
                          ),
                          const SizedBox(height: 16),
                          _inputField(
                            label: 'Number of Cards (1-78)',
                            icon: Icons.auto_awesome,
                            controller: countController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: isSmall ? 46 : 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _generateTarot,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isSmall ? 12 : 18,
                                  ),
                                  side: BorderSide(
                                    color: buttonBorderColor,
                                    width: 1.3,
                                  ),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black.withOpacity(0.22),
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmall ? 10 : 16,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Reveal My Cards',
                                      style: GoogleFonts.dmSans(
                                        fontSize: isSmall ? 15 : 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lightTarotAura() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x66C4B5FD), Color(0x00C4B5FD)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -30,
            child: Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x66FDE68A), Color(0x00FDE68A)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Always use pure white fill and pure black text for maximum clarity
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(color: Colors.black, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: label,
          hintStyle: GoogleFonts.dmSans(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _tarotTopBar(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    backgroundColor: isDark
        ? const Color(0xff050B1E)
        : Colors.white.withValues(alpha: 0.94),
    elevation: 0,
    centerTitle: true,
    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SizedBox(
          height: 38,
          width: 38,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    ),
    title: Text(
      'Tarot Reading',
      style: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    ),
  );
}
