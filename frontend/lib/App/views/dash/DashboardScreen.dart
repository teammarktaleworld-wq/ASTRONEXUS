import "package:astro_tale/App/views/Ai(chatbot)/View/Chatbot.dart";
import "package:astro_tale/App/views/Home/Screens/HomeScreen.dart";
import "package:astro_tale/App/views/options/optionscreen.dart";
import "package:astro_tale/App/views/profile/Screen/Profile.dart";
import "package:astro_tale/App/views/shop/store_screen.dart";
import "package:astro_tale/App/Model/Horoscope/horoscope_model.dart";
import "package:astro_tale/core/constants/app_assets.dart";
import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/core/localization/app_localizations.dart";
import "package:astro_tale/core/responsive/responsive.dart";
import "package:astro_tale/core/theme/app_gradients.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

class DashboardScreen extends StatefulWidget {
  final String zodiacSign;
  final HoroscopeData daily;
  final HoroscopeData weekly;
  final HoroscopeData monthly;

  const DashboardScreen({
    super.key,
    required this.zodiacSign,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final Homescreen _homePage;
  late final StoreScreen _shopPage;
  late final ServiceScreen _servicePage;
  late final CosmicProfileScreen _profilePage;

  final List<Map<String, dynamic>> _navItems = const <Map<String, dynamic>>[
    <String, dynamic>{"icon": LucideIcons.house, "label": "home"},
    <String, dynamic>{"icon": Icons.shopping_bag_outlined, "label": "shop"},
    <String, dynamic>{"icon": LucideIcons.bot, "label": "mati"},
    <String, dynamic>{"icon": LucideIcons.layoutDashboard, "label": "services"},
    <String, dynamic>{"icon": Icons.person_outline, "label": "profile"},
  ];

  @override
  void initState() {
    super.initState();
    _homePage = Homescreen(
      zodiacSign: widget.zodiacSign,
      daily: widget.daily,
      weekly: widget.weekly,
      monthly: widget.monthly,
    );
    _shopPage = const StoreScreen();
    _servicePage = const ServiceScreen();
    _profilePage = const CosmicProfileScreen();
  }

  void _onTabChanged(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildFloatingNavItem(int index) {
    final isActive = _selectedIndex == index;
    final isMiddle = index == 2;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeColor = theme.brightness == Brightness.dark
        ? Colors.white
        : colors.primary;
    final iconSize = context.responsiveValue(
      mobile: 22,
      tablet: 24,
      desktop: 26,
    );
    final middleSize = context.responsiveValue(
      mobile: 40,
      tablet: 44,
      desktop: 48,
    );
    final navIconColor = theme.brightness == Brightness.dark
        ? (isActive ? Colors.white : Colors.white54)
        : (isActive ? AppColors.lightPrimary : Colors.white70);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _onTabChanged(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: isMiddle
                  ? Container(
                      width: middleSize,
                      height: middleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.textSecondary,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(AppAssets.mati, fit: BoxFit.cover),
                      ),
                    )
                  : Icon(
                      _navItems[index]["icon"] as IconData,
                      size: isActive ? (iconSize + 5) : iconSize,
                      color: navIconColor,
                    ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.dmSans(
                fontSize: context.sp(11.5),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: navIconColor,
              ),
              child: Text(
                context.l10n.tr(_navItems[index]["label"].toString()),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 36 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDock(ThemeData theme) {
    return Container(
      key: const ValueKey<String>("bottom-dock"),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(theme).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white24,
          width: 1,
        ),
      ),
      height: context.responsiveValue(mobile: 74, tablet: 80, desktop: 86),
      child: Row(
        children: List<Widget>.generate(
          _navItems.length,
          _buildFloatingNavItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalInset = context.responsiveValue(
      mobile: 14,
      tablet: 26,
      desktop: 36,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _pageForIndex(_selectedIndex),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 5,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                child: _buildBottomDock(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return _homePage;
      case 1:
        return _shopPage;
      case 2:
        return const MatiChatBotScreen(bottomNavInset: 84);
      case 3:
        return _servicePage;
      case 4:
        return _profilePage;
      default:
        return _homePage;
    }
  }
}
