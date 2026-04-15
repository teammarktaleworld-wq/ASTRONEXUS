import 'dart:ui';
import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {
  final List<String> banners;
  final double height;

  const BannerSlider({super.key, required this.banners, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: banners.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(banners[index]),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
