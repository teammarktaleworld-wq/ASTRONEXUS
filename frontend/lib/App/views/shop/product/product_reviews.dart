import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductReviews extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const ProductReviews({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Text(
          "No reviews yet",
          style: GoogleFonts.poppins(color: Colors.white60),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = reviews[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r['user'] ?? 'Anonymous',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r['comment'] ?? '',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amberAccent,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
