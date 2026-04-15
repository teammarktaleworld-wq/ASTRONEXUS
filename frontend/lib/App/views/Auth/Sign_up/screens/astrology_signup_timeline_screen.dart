import 'dart:async';

import 'package:astro_tale/App/views/Auth/Sign_up/helper/step_birth_time.dart';
import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:astro_tale/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../core/widgets/animated_app_background.dart';
import '../../../dash/DashboardScreen.dart';
import '../controller/controller.dart';
import '../helper/StepPassword.dart';
import '../helper/step_birth_date.dart';
import '../helper/step_birth_place.dart';
import '../helper/step_email.dart';
import '../helper/step_name.dart';
import '../helper/step_phone.dart';
import '../widgets/signup_app_bar.dart';
import '../widgets/signup_card.dart';
import '../widgets/signup_stepper.dart';

class AstrologySignupTimeline extends StatefulWidget {
  const AstrologySignupTimeline({super.key});

  @override
  State<AstrologySignupTimeline> createState() =>
      _AstrologySignupTimelineState();
}

class _AstrologySignupTimelineState extends State<AstrologySignupTimeline> {
  int step = 0;
  late final SignupController controller = SignupController();
  bool _isSigningUp = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmController;
  late TextEditingController dobController;
  late TextEditingController placeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: controller.model.name);
    emailController = TextEditingController(text: controller.model.email);
    phoneController = TextEditingController(text: controller.model.phone);
    passwordController = TextEditingController(text: controller.model.password);
    confirmController = TextEditingController(
      text: controller.model.confirmPassword,
    );
    dobController = TextEditingController(text: controller.model.dateOfBirth);
    placeController = TextEditingController(text: controller.model.place);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    dobController.dispose();
    placeController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (step < 6) {
      setState(() => step++);
    }
  }

  void previousStep() {
    if (step > 0) {
      setState(() => step--);
    }
  }

  bool validateStep() {
    final model = controller.model;

    switch (step) {
      case 0:
        return model.name.trim().isNotEmpty;
      case 1:
        return model.email.trim().isNotEmpty && model.email.contains('@');
      case 2:
        final phone = model.phone.replaceAll(' ', '');
        return phone.isNotEmpty && phone.length >= 10;
      case 3:
        return model.password.isNotEmpty &&
            model.confirmPassword.isNotEmpty &&
            model.password == model.confirmPassword;
      case 4:
        return model.dateOfBirth.trim().isNotEmpty;
      case 5:
        return model.hour >= 0 && model.minute >= 0;
      case 6:
        return model.place.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> submitSignup() async {
    if (_isSigningUp) {
      return;
    }

    setState(() => _isSigningUp = true);

    try {
      final astrologyData = await controller.submitSignup();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            zodiacSign: astrologyData['zodiacSign'] ?? '',
            daily: astrologyData['daily'],
            weekly: astrologyData['weekly'],
            monthly: astrologyData['monthly'],
          ),
        ),
      );
    } on TimeoutException {
      _showError('Server is busy. Please wait and try again.');
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isSigningUp = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: isDark
              ? Colors.redAccent
              : theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return StepName(
          controller: nameController,
          onChanged: controller.setName,
        );
      case 1:
        return StepEmail(
          controller: emailController,
          onChanged: controller.setEmail,
        );
      case 2:
        return StepPhone(
          controller: phoneController,
          onChanged: controller.setPhone,
        );
      case 3:
        return StepPassword(
          passwordController: passwordController,
          confirmController: confirmController,
          onPasswordChanged: controller.setPassword,
          onConfirmChanged: controller.setConfirmPassword,
        );
      case 4:
        return StepBirthDate(
          controller: dobController,
          onChanged: controller.setDateOfBirth,
        );
      case 5:
        return StepBirthTime(
          model: controller.model,
          onChanged: () => setState(() {}),
        );
      case 6:
        return StepBirthPlace(
          controller: placeController,
          onChanged: controller.setPlace,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _nextButton() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSigningUp
              ? null
              : () {
                  if (!validateStep()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        width: 350,
                        behavior: SnackBarBehavior.floating,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        content: Center(
                          child: Text(
                            'Please complete this step correctly',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                    return;
                  }

                  if (step == 6) {
                    submitSignup();
                  } else {
                    nextStep();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: step == 6 && _isSigningUp
              ? LoadingAnimationWidget.fourRotatingDots(
                  color: colors.onPrimary,
                  size: 24,
                )
              : Text(
                  step == 6 ? 'Done' : 'Next',
                  style: GoogleFonts.dmSans(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: SignupAppBar(step: step, onBack: previousStep),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedAppBackground(
              showStarsInDark: true,
              showGlow: true,
              child: SizedBox(),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : AppColors.lightbox,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                bottom: keyboardInset > 0 ? keyboardInset : 0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      children: [
                        Text(
                          l10n.tr('modernSignupTitle'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: isDark ? Colors.white : colors.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tr('modernSignupSubtitle'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: isDark
                                ? Colors.white70
                                : colors.onSurface.withValues(alpha: 0.72),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SignupStepper(
                    step: step,
                    totalSteps: 7,
                    onStepChanged: (i) => setState(() => step = i),
                  ),
                  Expanded(child: SignupCard(child: _buildStep())),
                  _nextButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
