import 'dart:ui';
import 'package:astro_tale/App/views/shop/product/product_images_carousel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../util/formatters.dart';

class ProductDetailsSheet extends StatelessWidget {
  final String name;
  final double price;
  final String description;
  final List<String> images;

  const ProductDetailsSheet({
    super.key,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product carousel
              ProductImagesCarousel(images: images),
              const SizedBox(height: 16),
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Formatters.price(price),
                style: GoogleFonts.poppins(
                  color: Colors.amberAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
