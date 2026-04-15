import 'package:flutter/material.dart';

class ProductImagesCarousel extends StatelessWidget {
  final List<String> images;

  const ProductImagesCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: images.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(images[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
