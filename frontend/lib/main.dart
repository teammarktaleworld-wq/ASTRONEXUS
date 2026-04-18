import "package:astro_tale/App/controller/Auth_Controller.dart";
import "package:astro_tale/App/views/splash/SplashSreen.dart";
import "package:astro_tale/core/constants/app_constants.dart";
import "package:astro_tale/core/localization/app_localizations.dart";
import "package:astro_tale/core/responsive/responsive.dart";
import "package:astro_tale/core/settings/app_settings_controller.dart";
import "package:astro_tale/core/theme/app_theme.dart";
import "package:astro_tale/firebase_options.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthController.loadFromPrefs();
  await AppSettingsController.instance.load();
  runApp(const AstroNexusApp());
}

class AstroNexusApp extends StatelessWidget {
  const AstroNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettingsController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: AppSettingsController.instance.themeMode,
          locale: AppSettingsController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: AdaptiveTextScale.fromSize(media.size),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const Splashscreen(),
        );
      },
    );
  }
}
