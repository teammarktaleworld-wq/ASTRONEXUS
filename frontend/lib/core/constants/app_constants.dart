import "package:astro_tale/core/constants/api_constants.dart";
import "package:astro_tale/core/constants/app_assets.dart";

class AppConstants {
  const AppConstants._();

  static const String appName = "AstroNexus";
  static const String appTagLine = "Astro insights, simplified";

  static const double mobileBreakpoint = 360;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static const Duration apiTimeout = Duration(seconds: 25);

  static const String birthchartApi = ApiConstants.birthChartApi;

  static const String bannerShopOne = AppAssets.bannerShopOne;
  static const String bannerShopTwo = AppAssets.bannerShopTwo;
}
