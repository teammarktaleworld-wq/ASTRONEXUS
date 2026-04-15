import 'package:astro_tale/util/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_fonts/google_fonts.dart';

class AstrologyLoginScreen extends StatelessWidget {
  const AstrologyLoginScreen({super.key});

  // ---- MOCK AUTH METHODS (Replace with your API calls) ---- //
  Future<String?> _loginUser(LoginData data) async {
    await Future.delayed(const Duration(seconds: 1));
    if (data.name == "astro@demo.com" && data.password == "123456") {
      return null;
    }
    return "Invalid credentials";
  }

  Future<String?> _signupUser(SignupData data) async {
    await Future.delayed(const Duration(seconds: 1));
    final fullName = data.additionalSignupData?['Full Name'];
    final phoneNumber = data.additionalSignupData?['Phone Number'];

    if (fullName == null || fullName.isEmpty) return "Full Name is required";
    if (phoneNumber == null || phoneNumber.isEmpty)
      return "Phone Number is required";

    return null;
  }

  Future<String?> _recoverPassword(String name) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---- Background gradient ---- //
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B0B0F), Color(0xFF1C1C2C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // ---- Star overlay ---- //
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/images/bg.png', // subtle starry background
              fit: BoxFit.cover,
            ),
          ),
        ),
        // ---- Glow overlay ---- //
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.02), Colors.transparent],
                radius: 0.9,
                center: Alignment.topLeft,
              ),
            ),
          ),
        ),
        // ---- Login Form ---- //
        Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 320, // controls the form width
              child: FlutterLogin(
                title: 'AstroVerse',
                logo: const AssetImage(Images.logo),
                onLogin: _loginUser,
                onSignup: _signupUser,
                onRecoverPassword: _recoverPassword,
                onSubmitAnimationCompleted: () {
                  Navigator.pushReplacementNamed(context, "/signupSteps");
                },
                additionalSignupFields: const [
                  UserFormField(
                    keyName: 'Full Name',
                    displayName: 'Full Name',
                    userType: LoginUserType.name,
                  ),
                  UserFormField(
                    keyName: 'Phone Number',
                    displayName: 'Phone Number',
                    userType: LoginUserType.phone,
                  ),
                ],
                theme: LoginTheme(
                  primaryColor: Colors.transparent,
                  accentColor: Colors.white,
                  errorColor: Colors.redAccent,
                  pageColorLight: Colors.transparent,
                  pageColorDark: Colors.transparent,
                  titleStyle: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 6,
                        color: Color(0xFFFFD700), // golden glow
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  bodyStyle: GoogleFonts.poppins(color: Colors.white70),
                  textFieldStyle: GoogleFonts.poppins(color: Colors.white),
                  cardTheme: CardTheme(
                    color: Colors.black87.withOpacity(0.85),
                    elevation: 14,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: Color(0xFFFFD700),
                        width: 1,
                      ),
                    ),
                  ),
                  inputTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  buttonTheme: LoginButtonTheme(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    highlightColor: Colors.white.withOpacity(0.3),
                    splashColor: Colors.white24,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                messages: LoginMessages(
                  userHint: 'Email / Phone',
                  passwordHint: 'Password',
                  confirmPasswordHint: 'Confirm Password',
                  loginButton: 'Login',
                  signupButton: 'Create Account',
                  forgotPasswordButton: 'Forgot password?',
                  recoverPasswordButton: 'Recover',
                  goBackButton: 'Back',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
