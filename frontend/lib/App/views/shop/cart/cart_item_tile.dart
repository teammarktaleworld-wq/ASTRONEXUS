import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../util/formatters.dart';

class CartItemTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Name + Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.price(price),
                      style: GoogleFonts.poppins(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Quantity selector
                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              onQuantityChanged?.call(quantity - 1),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '$quantity',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              onQuantityChanged?.call(quantity + 1),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
