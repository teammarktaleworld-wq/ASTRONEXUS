import "package:astro_tale/core/constants/app_assets.dart";
import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/core/constants/app_constants.dart";
import "package:flutter/material.dart";

class AppConstant {
  const AppConstant._();

  static const String appName = AppConstants.appName;
  static const String AppName = appName;

  static const Color lightprimary = AppColors.lightPrimary;
  static const Color secondary = AppColors.secondary;
  static const Color darkprimary = AppColors.darkPrimary;

  static const String birthchartAPI = AppConstants.birthchartApi;

  static const String banner_shop1 = AppAssets.bannerShopOne;
  static const String banner_shop2 = AppAssets.bannerShopTwo;
}
