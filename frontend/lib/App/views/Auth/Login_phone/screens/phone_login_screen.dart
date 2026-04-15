import "package:astro_tale/App/views/Auth/Sign_up/screens/astrology_signup_timeline_screen.dart";
import "package:astro_tale/core/widgets/animated_app_background.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:astro_tale/App/views/Auth/terms%20and%20condition/termsandconditions.dart";

import "../../../../../ui_componets/glass/glass_card.dart";
import "../../Login_email/screens/signin_screen.dart";
import "../controller/phone_login_controller.dart";
import "../helper/phone_login_helpers.dart";
import "../widgets/phone_login_widgets.dart";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? phoneNumber;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AnimatedAppBackground(child: _content()));
  }

  Widget _content() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Image.asset("assets/images/logo.png", height: 150),
            Text(
              "Discover the stars within you",
              style: GoogleFonts.dmSans(
                color: isDark
                    ? Colors.white70
                    : colors.onSurface.withValues(alpha: 0.72),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            glassCard(
              child: Column(
                children: [
                  Text(
                    "Login with Phone",
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "OTP verification for secure login",
                    style: GoogleFonts.dmSans(
                      color: colors.onSurface.withValues(alpha: 0.62),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  intlPhoneInput(
                    initialCountryCode: "IN",
                    onChanged: (value) => phoneNumber = value,
                  ),
                  const SizedBox(height: 16),
                  SendOtpButton(
                    loading: loading,
                    onTap: () => PhoneLoginController.sendOtp(
                      context: context,
                      phoneNumber: phoneNumber,
                      onStart: () => setState(() => loading = true),
                      onStop: () => setState(() => loading = false),
                    ),
                  ),
                  const SizedBox(height: 16),
                  orDivider(context),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignIn()),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colors.onSurface.withValues(alpha: 0.42),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Login with Email",
                        style: GoogleFonts.dmSans(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: GoogleFonts.dmSans(
                          color: colors.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AstrologySignupTimeline(),
                          ),
                        ),
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.dmSans(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsAndConditions()),
              ),
              child: Text(
                "Terms And Conditions",
                style: GoogleFonts.dmSans(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
