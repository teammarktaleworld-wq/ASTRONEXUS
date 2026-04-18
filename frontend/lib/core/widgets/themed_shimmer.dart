import "package:astro_tale/core/constants/app_colors.dart";
import "package:flutter/material.dart";
import "package:shimmer/shimmer.dart";

class ThemedShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry margin;

  const ThemedShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 12,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    const base = AppColors.shimmerBase;
    const highlight = AppColors.shimmerHighlight;

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1200),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}

class ThemedShimmerCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;

  const ThemedShimmerCard({
    super.key,
    this.height = 180,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ThemedShimmerBox(width: 140, height: 16),
          const SizedBox(height: 14),
          const ThemedShimmerBox(height: 12),
          const SizedBox(height: 8),
          const ThemedShimmerBox(height: 12),
          const SizedBox(height: 8),
          const ThemedShimmerBox(height: 12, width: 240),
          const Spacer(),
          const ThemedShimmerBox(width: 80, height: 10, radius: 8),
        ],
      ),
    );
  }
}
