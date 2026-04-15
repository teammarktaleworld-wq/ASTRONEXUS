import 'package:astro_tale/App/controller/Auth_Controller.dart';
import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:astro_tale/App/views/subscription/views/subscription_screen.dart';
import 'package:astro_tale/App/views/wallet/screen/wallet_screen.dart';
import '../../shop/orders/my_orders_screen.dart';
import '../../wishlist/screen/wishlist_screen.dart';
import '../others/birthdetails_screen/birth_details_screen.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuCard(
          title: "Birth Details / Kundli",
          icon: LucideIcons.cake,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BirthDetailsScreen()),
            );
          },
        ),

        const SizedBox(height: 12),

        _MenuCard(
          title: "Wishlist",
          icon: LucideIcons.heart,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            );
          },
        ),

        const SizedBox(height: 12),

        _MenuCard(
          title: "My Orders",
          icon: LucideIcons.package,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            );
          },
        ),

        const SizedBox(height: 12),

        /// ✅ WALLET (FIXED)
        _MenuCard(
          title: "Wallet & Payments",
          icon: LucideIcons.wallet,
          onTap: () {
            final userId = AuthController.userId;

            if (userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please login again")),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WalletScreen(userId: userId)),
            );
          },
        ),

        const SizedBox(height: 12),

        _MenuCard(
          title: "Subscriptions",
          icon: LucideIcons.crown,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SubscriptionPage()),
            );
          },
        ),
      ],
    );
  }
}

/*────────────────── MENU CARD ──────────────────*/
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? AppGradients.glassFill(theme)
        : AppColors.lightContainerAlt;
    final borderColor = AppGradients.glassBorder(theme);
    final iconBg = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.16);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.3 : 0.22);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),

            const SizedBox(width: 14),

            /// TITLE
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            /// ARROW
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
