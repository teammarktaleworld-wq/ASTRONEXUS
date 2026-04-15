import "package:astro_tale/core/constants/api_constants.dart";

class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = ApiConstants.userBaseUrl;

  static const String horoscopeUrl =
      "${ApiConstants.legacyHoroscopeBaseUrl}?sign=leo&type=daily&day=TODAY";
  static const String Horoscopeurl = horoscopeUrl;

  static const String me = "/me";
  static const String signupAstrology = "/signup/astrology";
  static const String login = "/login";
  static const String loginPhone = "/login/phone";

  static const String categories = "/categories";
  static const String products = "/products";
  static const String homeProducts = "/home-products";

  static const String wishlist = "/wishlist";
  static const String wishlistRemove = "/wishlist/remove";

  static const String cart = "/cart";
  static const String addToCart = "/cart/add";
  // Backend currently uses the same route for add/update quantity.
  static const String updateCart = "/cart/add";
  static const String removeCart = "/cart/remove";

  static const String orders = "/orders";
  static const String ordersMy = "/orders/my";
  static const String placeOrder = "/orders";

  static const String addresses = "/addresses";
  static const String addAddress = "/addresses/add";

  static const String createPayment = "/payment/create";
  static const String verifyPayment = "/payment/verify";
}
