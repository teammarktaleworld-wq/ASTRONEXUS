import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../util/formatters.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final VoidCallback? onCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.75);

    final borderColor = isDark
        ? Colors.amberAccent.withOpacity(0.35)
        : const Color(0xFF555879).withOpacity(0.25);

    final shadowColor = isDark
        ? Colors.black.withOpacity(0.45)
        : Colors.black.withOpacity(0.08);

    final dividerColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.08);

    final buttonColor = isDark
        ? Colors.amberAccent
        : const Color(0xFF332D56);

    final buttonTextColor = isDark
        ? Colors.black
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _row(context, "Subtotal", subtotal),
                  const SizedBox(height: 8),
                  _row(
                    context,
                    "Discount",
                    discount,
                    valueColor: Colors.redAccent.withOpacity(0.85),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: dividerColor),
                  const SizedBox(height: 10),
                  _row(context, "Total", total, isTotal: true),
                  const SizedBox(height: 18),

                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onCheckout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Checkout",
                          style: GoogleFonts.dmSans(
                            color: buttonTextColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context,
      String label,
      double value, {
        bool isTotal = false,
        Color? valueColor,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelColor = isDark
        ? Colors.white.withOpacity(isTotal ? 1 : 0.75)
        : const Color(0xFF332D56).withOpacity(isTotal ? 1 : 0.75);

    final defaultValueColor = isDark
        ? (isTotal ? Colors.amberAccent : Colors.white70)
        : (isTotal
        ? const Color(0xFF332D56)
        : const Color(0xFF555879));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: labelColor,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          Formatters.price(value),
          style: GoogleFonts.dmSans(
            color: valueColor ?? defaultValueColor,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}