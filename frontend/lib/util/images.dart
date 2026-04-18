import "package:astro_tale/core/constants/app_assets.dart";

class Images {
  const Images._();

  static const String logo = AppAssets.logo;
  static const String astronexus = AppAssets.astronexus;
  static const String background = AppAssets.background;
  static const String onboard1 = AppAssets.onboardingOne;
  static const String onboard2 = AppAssets.onboardingTwo;
  static const String onboard3 = AppAssets.onboardingThree;
  static const String onboard4 = AppAssets.onboardingFour;
  static const String login = AppAssets.login;
  static const String forgetpassword = AppAssets.forgetPassword;
  static const String morningpuja = AppAssets.morningPuja;
  static const String eveningpuja = AppAssets.eveningPuja;
  static const String rituals = AppAssets.rituals;
  static const String daily = AppAssets.daily;
  static const String medition = AppAssets.daily;
  static const String mati = AppAssets.mati;

  static const String flag = AppAssets.flagIcon;
  static const String signup = AppAssets.signUp;
  static const String otp = AppAssets.otp;
  static const String signin = AppAssets.signIn;
  static const String home = AppAssets.homeIcon;
  static const String chat = AppAssets.chatIcon;
  static const String videocall = AppAssets.videoCallIcon;
  static const String profile = AppAssets.profileIcon;
  static const String banner_one = AppAssets.bannerOne;
  static const String banner_two = AppAssets.bannerTwoJpg;
  static const String banner_three = AppAssets.bannerThree;
  static const String astro = AppAssets.astroLogo;
  static const String dash = AppAssets.dashboardIcon;

  static const List<String> all = <String>[
    "assets/animation/loading.gif",
    "assets/astrology/astrology.png",
    "assets/astrology/horoscope.png",
    "assets/astrology/kundli.png",
    "assets/astrology/love.png",
    "assets/astrology/numerology.png",
    "assets/astrology/nutrition.png",
    "assets/astrology/store.png",
    "assets/astrology/tarot.png",
    "assets/horoscope/aquarius.png",
    "assets/horoscope/aries.png",
    "assets/horoscope/cancer.png",
    "assets/horoscope/capricorn.png",
    "assets/horoscope/gemini.png",
    "assets/horoscope/leo.png",
    "assets/horoscope/libra.png",
    "assets/horoscope/pisces.png",
    "assets/horoscope/sagittarius.png",
    "assets/horoscope/scorpio.png",
    "assets/horoscope/taurus.png",
    "assets/horoscope/virgo.png",
    "assets/icons/ascending.png",
    "assets/icons/birth_chart.png",
    "assets/icons/career.png",
    "assets/icons/chat.png",
    "assets/icons/daily.png",
    "assets/icons/dashboard.png",
    "assets/icons/flag.png",
    "assets/icons/health.png",
    "assets/icons/home.png",
    "assets/icons/horoscope.png",
    "assets/icons/love.png",
    "assets/icons/love12.png",
    "assets/icons/moon.png",
    "assets/icons/profile.png",
    "assets/icons/search.png",
    "assets/icons/sun.png",
    "assets/icons/tarot.png",
    "assets/icons/videocall.png",
    "assets/images/astrobot.png",
    "assets/images/astrologo.png",
    "assets/images/astronexus.png",
    "assets/images/AstroTale.png",
    "assets/images/backgroundAstro.jpg",
    "assets/images/banner_chart.jpeg",
    "assets/images/banner_mati.jpeg",
    "assets/images/banner_one.png",
    "assets/images/banner_shop_one.jpeg",
    "assets/images/banner_shop_two.jpeg",
    "assets/images/banner_tarot.jpeg",
    "assets/images/banner_three.png",
    "assets/images/banner_two.jpg",
    "assets/images/banner_two.png",
    "assets/images/bg.png",
    "assets/images/bg_banner.png",
    "assets/images/bg_card.jpg",
    "assets/images/bg_card.png",
    "assets/images/bg_home.png",
    "assets/images/bg_horoscope.png",
    "assets/images/bg_result.jpg",
    "assets/images/bg_tarot.png",
    "assets/images/bg12.png",
    "assets/images/birth_one.png",
    "assets/images/birthchart.png",
    "assets/images/daily.png",
    "assets/images/evening.png",
    "assets/images/forget.png",
    "assets/images/horoscope.png",
    "assets/images/login.png",
    "assets/images/logo.png",
    "assets/images/logo_icon.jpg",
    "assets/images/logo2.png",
    "assets/images/mati.png",
    "assets/images/morning.png",
    "assets/images/onboard_four.png",
    "assets/images/onboard_one.png",
    "assets/images/onboard_three.png",
    "assets/images/onboard_two.png",
    "assets/images/otp.png",
    "assets/images/place.png",
    "assets/images/ritual.png",
    "assets/images/signin.png",
    "assets/images/signup.png",
    "assets/images/tarot_card.png",
    "assets/images/tarot_icon.png",
    "assets/images/time.png",
    "assets/nutrition/chakra_leaf.png",
    "assets/nutrition/food.png",
    "assets/nutrition/zodaic_food.png",
    "assets/planets/planet1.png",
    "assets/planets/planet2.png",
    "assets/planets/planet3.png",
    "assets/reports/annual.png",
    "assets/reports/billionaire.png",
    "assets/reports/business.png",
    "assets/reports/career.png",
    "assets/reports/health.png",
    "assets/reports/income.png",
    "assets/reports/investment.png",
    "assets/reports/life.png",
    "assets/reports/luxury.png",
    "assets/reports/passive.png",
    "assets/reports/personality.png",
    "assets/reports/property.png",
    "assets/reports/relationship.png",
    "assets/reports/risk.png",
    "assets/reports/spiritual.png",
    "assets/reports/wealth.png",
    "assets/reports/wellness.png",
    "assets/stars/stars.png",
    "assets/support/astrologer.jpg",
    "assets/support/help.jpg",
    "assets/tarot/tarot_banner.jpg",
    "assets/tarot/tarot_one.png",
    "assets/tarot/tarot_three.png",
    "assets/tarot/tarot_two.png",
  ];

  static bool exists(String path) => all.contains(path);
  static String use(String path) => exists(path) ? path : path;
}
