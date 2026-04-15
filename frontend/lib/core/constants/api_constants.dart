class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = "https://astro-nexus-new-6-46mo.onrender.com";
  static const String userBaseUrl = "$baseUrl/user";
  static const String authBaseUrl = "https://auth-astronexus-1.onrender.com";

  static const String horoscopeBaseUrl =
      "https://astronexus-backend.onrender.com/api/unified/horoscope";
  static const String legacyHoroscopeBaseUrl =
      "https://astronexus-backend.onrender.com/api/unified/horoscope";

  static const String birthChartApi =
      "https://astronexus-backend.onrender.com/api/unified/birth-chart";
  static const String legacyBirthChartApi =
      "https://astronexus-backend.onrender.com/api/unified/birth-chart";
  static const String birthChartGenerateApi =
      "$baseUrl/api/birthchart/generate";
  static const List<String> birthChartImageBaseCandidates = <String>[
    baseUrl,
    "https://astro-nexus-backend-9u1s.onrender.com",
    "https://astro-nexus-backend.onrender.com",
  ];

  static const String chatbotAskApi =
      "https://astronexus-backend.onrender.com/api/unified/mati-chat";
  static const String geocodeApi =
      "https://maps.googleapis.com/maps/api/geocode/json";
  static const String citySearchApi = "https://photon.komoot.io/api/";
}
