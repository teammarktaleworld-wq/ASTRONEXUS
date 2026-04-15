import "package:astro_tale/App/views/Auth/Forget_Password/forgetpassword.dart";
import "package:astro_tale/App/views/Auth/Sign_up/screens/astrology_signup_timeline_screen.dart";
import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/core/widgets/animated_app_background.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:astro_tale/ui_componets/glass/glass_card.dart";

import "../../terms and condition/termsandconditions.dart";
import "../controller/signin_controller.dart";
import "../helper/signin_helpers.dart";
import "../widgets/signin_widgets.dart";

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool obscure = true;
  bool remember = false;
  bool loading = false;

  final email = TextEditingController();
  final password = TextEditingController();

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
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            Image.asset("assets/images/logo.png", height: 120),
            const SizedBox(height: 12),
            Text(
              "Discover the stars within you",
              style: GoogleFonts.dmSans(
                color: isDark
                    ? Colors.white70
                    : colors.onSurface.withValues(alpha: 0.72),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            glassCard(
              child: Column(
                children: [
                  Text(
                    "Sign In",
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "Continue your cosmic journey",
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    style: GoogleFonts.dmSans(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: authInput(context, "Email", Icons.person),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: obscure,
                    style: GoogleFonts.dmSans(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration:
                        authInput(
                          context,
                          "Password",
                          Icons.password_sharp,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: AppColors.textPrimary,
                            value: remember,
                            onChanged: (v) => setState(() => remember = v!),
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPassword(),
                            ),
                          );
                        },
                        child: Text(
                          "Forget Password?",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoginButton(
                    loading: loading,
                    onTap: () => SignInController.login(
                      context: context,
                      email: email,
                      password: password,
                      rememberMe: remember,
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
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.textPrimary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Sign in with Phone",
                        style: GoogleFonts.dmSans(
                          color: AppColors.textPrimary,
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
                          color: AppColors.textPrimary,
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
