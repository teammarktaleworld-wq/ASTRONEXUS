import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/core/localization/app_localizations.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final ValueChanged<String> onItemTap;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;
  final Locale currentLocale;
  final ValueChanged<Locale> onLanguageChanged;

  const CustomDrawer({
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.onItemTap,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
    required this.currentLocale,
    required this.onLanguageChanged,
    super.key,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
  }

  @override
  void didUpdateWidget(covariant CustomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocale.languageCode !=
        widget.currentLocale.languageCode) {
      _selectedLocale = widget.currentLocale;
    }
  }

  Widget _profileHeader(ThemeData theme) {
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.primary.withOpacity(
              theme.brightness == Brightness.dark ? 0.45 : 0.18,
            ),
            colors.surface,
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withOpacity(0.35),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: colors.surface,
              child: ClipOval(
                child:
                    widget.userAvatar != null && widget.userAvatar!.isNotEmpty
                    ? Image.network(
                        widget.userAvatar!,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 46,
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 46,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.userName.isEmpty
                ? context.l10n.tr("guest")
                : widget.userName,
            style: GoogleFonts.dmSans(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.userEmail,
            style: GoogleFonts.dmSans(
              color: colors.onSurface.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeChooser(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkSelected = widget.currentThemeMode != ThemeMode.light;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.tr("theme"),
            style: GoogleFonts.dmSans(
              color: colors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withOpacity(0.28)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    isDarkSelected
                        ? l10n.tr("darkMode")
                        : l10n.tr("allWhiteMode"),
                    style: GoogleFonts.dmSans(
                      color: colors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isDarkSelected,
                  activeThumbColor: AppColors.onDark,
                  activeTrackColor: AppColors.appBarDark,
                  onChanged: (enabled) {
                    widget.onThemeModeChanged(
                      enabled ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageChooser(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.language,
            color: colors.onSurface.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.tr("language"),
              style: GoogleFonts.dmSans(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: _selectedLocale,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: colors.surface,
              style: GoogleFonts.dmSans(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              items: <DropdownMenuItem<Locale>>[
                DropdownMenuItem<Locale>(
                  value: const Locale("en"),
                  child: Text(l10n.tr("english")),
                ),
                DropdownMenuItem<Locale>(
                  value: const Locale("fr"),
                  child: Text(l10n.tr("french")),
                ),
                DropdownMenuItem<Locale>(
                  value: const Locale("de"),
                  child: Text(l10n.tr("german")),
                ),
              ],
              onChanged: (locale) {
                if (locale == null) {
                  return;
                }
                setState(() => _selectedLocale = locale);
                widget.onLanguageChanged(locale);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      horizontalTitleGap: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final menuItems = <_DrawerItem>[
      _DrawerItem(
        id: "terms",
        label: l10n.tr("termsConditions"),
        icon: Icons.description_outlined,
      ),
      _DrawerItem(
        id: "wishlist",
        label: l10n.tr("wishlist"),
        icon: Icons.favorite_border,
      ),
      _DrawerItem(
        id: "match",
        label: l10n.tr("matchServices"),
        icon: Icons.auto_awesome_motion_outlined,
      ),
      _DrawerItem(
        id: "support",
        label: l10n.tr("support"),
        icon: Icons.support_agent,
      ),
      _DrawerItem(
        id: "rate",
        label: l10n.tr("rateUs"),
        icon: Icons.star_border,
      ),
      _DrawerItem(
        id: "like",
        label: l10n.tr("like"),
        icon: Icons.thumb_up_alt_outlined,
      ),
    ];

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundSoft
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            _profileHeader(theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                children: <Widget>[
                  ...menuItems.map(
                    (item) => _menuItem(
                      icon: item.icon,
                      title: item.label,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onItemTap(item.id);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _themeChooser(context),
                  const SizedBox(height: 12),
                  _languageChooser(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}
