import "package:flutter/material.dart";

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale("en"),
    Locale("fr"),
    Locale("de"),
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? AppLocalizations(const Locale("en"));
  }

  static const Map<String, Map<String, String>>
  _values = <String, Map<String, String>>{
    "en": <String, String>{
      "language": "Language",
      "english": "English",
      "french": "French",
      "german": "German",
      "darkMode": "Dark Mode",
      "allWhiteMode": "Light Theme",
      "systemMode": "System",
      "theme": "Theme",
      "home": "Home",
      "shop": "Shop",
      "services": "Services",
      "mati": "Mati",
      "profile": "Profile",
      "guest": "Guest",
      "greetingHi": "Hi,",
      "welcomeBack": "Welcome back!",
      "today": "Today",
      "week": "Week",
      "month": "Month",
      "searchProducts": "Search products...",
      "subscriptionPlans": "Subscription Plans",
      "upgradeJourney": "Upgrade Your Journey",
      "subscribe": "Subscribe",
      "choosePhoto": "Choose Photo",
      "viewPhoto": "View Photo",
      "cancel": "Cancel",
      "forgetPassword": "Forgot Password",
      "sendOtp": "Send OTP",
      "loginWithEmail": "Login with Email",
      "signUp": "Sign up",
      "new": "New",
      "wishlist": "Wishlist",
      "cart": "Cart",
      "termsConditions": "Terms & Conditions",
      "matchServices": "Match Services",
      "support": "Support",
      "rateUs": "Rate Us",
      "like": "Like",
      "subscriptionHint":
          "Choose a plan that aligns with your spiritual path and unlock deeper astrological insights.",
      "modernSignupTitle": "Create Your Cosmic Account",
      "modernSignupSubtitle":
          "Quick setup with your personal birth details for accurate guidance.",
      "birthChart": "Birth Chart",
      "generateChart": "Generate Chart",
      "chartImageUnavailable": "Chart image not available",
      "birthInformation": "Birth Information",
      "astrologyDetails": "Astrology Details",
      "name": "Name",
      "date": "Date",
      "time": "Time",
      "place": "Place",
      "rashi": "Rashi",
      "nakshatra": "Nakshatra",
      "lagna": "Lagna",
      "currentMahadasha": "Current Mahadasha",
      "planet": "Planet",
      "period": "Period",
      "ascendant": "Ascendant",
      "downloadPdf": "Download PDF",
      "generatedBirthChart": "Generated Birth Chart",
      "noPlanets": "No planets",
    },
    "fr": <String, String>{
      "language": "Langue",
      "english": "Anglais",
      "french": "Francais",
      "german": "Allemand",
      "darkMode": "Mode sombre",
      "allWhiteMode": "Theme clair",
      "theme": "Theme",
      "home": "Accueil",
      "shop": "Boutique",
      "services": "Services",
      "mati": "Mati",
      "profile": "Profil",
      "guest": "Invite",
      "greetingHi": "Salut,",
      "welcomeBack": "Bon retour !",
      "today": "Aujourd'hui",
      "week": "Semaine",
      "month": "Mois",
    },
    "de": <String, String>{
      "language": "Sprache",
      "english": "Englisch",
      "french": "Franzoesisch",
      "german": "Deutsch",
      "darkMode": "Dunkelmodus",
      "allWhiteMode": "Helles Design",
      "theme": "Thema",
      "home": "Start",
      "shop": "Shop",
      "services": "Dienste",
      "mati": "Mati",
      "profile": "Profil",
      "guest": "Gast",
      "greetingHi": "Hallo,",
      "welcomeBack": "Willkommen zurueck!",
      "today": "Heute",
      "week": "Woche",
      "month": "Monat",
    },
  };

  String tr(String key) {
    final code = locale.languageCode;
    return _values[code]?[key] ?? _values["en"]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
