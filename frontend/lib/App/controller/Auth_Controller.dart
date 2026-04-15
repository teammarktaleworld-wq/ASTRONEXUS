import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController {
  static String token = "";
  static String refreshToken = "";
  static String userId = "";
  static String role = "";

  /// Load auth data from SharedPreferences
  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("auth_token") ?? "";
    refreshToken = prefs.getString("refresh_token") ?? "";
    userId = prefs.getString("userId") ?? "";
    role = prefs.getString("role") ?? "";
  }

  /// Check if user is logged in
  static bool get isLoggedIn {
    if (token.isEmpty) return false;
    return !JwtDecoder.isExpired(token);
  }

  /// Save auth data
  static Future<void> setTokens({
    required String newToken,
    String? newRefreshToken,
    String? newUserId,
    String? newRole,
  }) async {
    token = newToken;
    if (newRefreshToken != null) refreshToken = newRefreshToken;
    if (newUserId != null) userId = newUserId;
    if (newRole != null) role = newRole;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    if (newRefreshToken != null)
      await prefs.setString("refresh_token", refreshToken);
    if (newUserId != null) await prefs.setString("userId", userId);
    if (newRole != null) await prefs.setString("role", role);
  }
}
