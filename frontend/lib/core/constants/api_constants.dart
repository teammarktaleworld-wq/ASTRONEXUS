class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = "https://astronexus-live.onrender.com";
  static const String userBaseUrl = "$baseUrl/user";
  static const String authBaseUrl = "https://astronexus-live.onrender.com";

  static const String horoscopeBaseUrl =
      "$baseUrl/api/unified/horoscope";
  static const String legacyHoroscopeBaseUrl =
      "$baseUrl/api/unified/horoscope";

  static const String birthChartApi =
      "$baseUrl/api/unified/birth-chart";
  static const String legacyBirthChartApi =
      "$baseUrl/api/unified/birth-chart";
  static const String birthChartGenerateApi =
      "$baseUrl/api/birthchart/generate";
  static const List<String> birthChartImageBaseCandidates = <String>[
    baseUrl,
    "https://astronexus-live.onrender.com",
    "https://astro-nexus-backend.onrender.com",
  ];

  static const String chatbotAskApi =
      "$baseUrl/api/unified/mati-chat";
  static const String geocodeApi =
      "https://maps.googleapis.com/maps/api/geocode/json";
  static const String citySearchApi = "https://photon.komoot.io/api/";
}
