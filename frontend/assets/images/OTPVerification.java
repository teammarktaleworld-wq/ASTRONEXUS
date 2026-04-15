import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPVerification extends StatefulWidget {
  const OTPVerification({super.key});

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Top Illustration
            Image.asset(
              'assets/images/otp.png', // Replace with your OTP image
              width: 280,
              height: 260,
              fit: BoxFit.contain,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.58,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff272757),
                      Color(0xff4A4A77),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "OTP Verification",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "An 4 digit code has been sent to your number",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // OTP Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 55,
                            child: TextField(
                              controller: otpControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // Verify OTP button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            String otp = otpControllers
                                .map((controller) => controller.text)
                                .join();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Entered OTP: $otp")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff4A4A77),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Verify OTP",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Resend Text
                      RichText(
                        text: TextSpan(
                          text: "If you didn’t receive a code! ",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Resend",
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Terms and Conditions
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Terms And Conditions",
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFFFFC107),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
