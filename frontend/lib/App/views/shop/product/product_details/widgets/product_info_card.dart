import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../Model/product_model.dart';
import '../helper/ product_helpers.dart';

class ProductInfoCard extends StatelessWidget {
  final ProductModel product;
  const ProductInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "₹${product.price}",
                style: GoogleFonts.poppins(
                  color: Colors.amberAccent,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _chip(astrologyLabel(product.astrologyType)),
                  _chip(deliveryLabel(product.deliveryType)),
                  _chip(
                    stockLabel(product.stock),
                    color: product.stock > 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.description ?? '',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, {Color color = Colors.blueAccent}) {
    return Chip(
      backgroundColor: color.withOpacity(.2),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
}
