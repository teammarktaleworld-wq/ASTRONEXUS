import "dart:math" as math;

import "package:astro_tale/core/constants/app_constants.dart";
import "package:flutter/widgets.dart";

extension ResponsiveContext on BuildContext {
  MediaQueryData get media => MediaQuery.of(this);
  Size get size => media.size;
  double get width => size.width;
  double get height => size.height;

  bool get isSmallPhone => width < AppConstants.mobileBreakpoint;
  bool get isTablet => width >= AppConstants.tabletBreakpoint;
  bool get isDesktop => width >= AppConstants.desktopBreakpoint;

  double wp(double fraction) => width * fraction;
  double hp(double fraction) => height * fraction;

  double sp(double value) {
    final scaleByWidth = width / 390;
    final clamped = scaleByWidth.clamp(0.86, 1.2);
    return value * clamped;
  }

  EdgeInsets get pagePadding {
    if (isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet ?? mobile;
    }
    if (isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

class AdaptiveTextScale {
  const AdaptiveTextScale._();

  static TextScaler fromSize(Size size) {
    final shortestSide = math.min(size.width, size.height);
    final scale = (shortestSide / 390).clamp(0.92, 1.12);
    return TextScaler.linear(scale);
  }
}
