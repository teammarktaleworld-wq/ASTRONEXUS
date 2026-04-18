import 'package:flutter/material.dart';

class ProductImageSlider extends StatelessWidget {
  final List<String> images;
  const ProductImageSlider({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final list = images.isNotEmpty
        ? images
        : ["https://via.placeholder.com/400"];

    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => Image.network(
          list[i],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}
