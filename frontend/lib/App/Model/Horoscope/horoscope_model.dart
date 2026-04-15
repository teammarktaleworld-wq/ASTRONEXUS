class HoroscopeData {
  final String title;
  final String text;

  HoroscopeData({required this.title, required this.text});

  factory HoroscopeData.fromJson(Map<String, dynamic> json) {
    final nested = _asMap(json["data"]);
    final deepNested = _asMap(nested["data"]);
    return HoroscopeData(
      title: _firstNonEmptyString(<dynamic>[
        json["title"],
        json["date"],
        json["week"],
        json["month"],
        nested["title"],
        nested["date"],
        nested["week"],
        nested["month"],
        deepNested["title"],
        deepNested["date"],
        deepNested["week"],
        deepNested["month"],
      ]),
      text: _firstNonEmptyString(<dynamic>[
        json["horoscope"],
        json["horoscope_data"],
        json["prediction"],
        json["text"],
        json["content"],
        nested["horoscope"],
        nested["horoscope_data"],
        nested["prediction"],
        nested["text"],
        nested["content"],
        deepNested["horoscope"],
        deepNested["horoscope_data"],
        deepNested["prediction"],
        deepNested["text"],
        deepNested["content"],
      ]),
    );
  }

  Map<String, dynamic> toJson() => {"title": title, "horoscope": text};

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }

  static String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? "";
      if (text.isNotEmpty) {
        return text;
      }
    }
    return "";
  }
}
