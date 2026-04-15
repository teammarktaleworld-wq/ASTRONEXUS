import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductReviewSection extends StatelessWidget {
  final String productId;
  const ProductReviewSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Customer Reviews"),
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (_) {},
        ),
      ],
    );
  }
}
