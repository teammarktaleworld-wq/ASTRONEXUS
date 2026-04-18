class PlaceSuggestion {
  final String name;
  final String country;
  final double lat;
  final double lon;

  PlaceSuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] ?? {};
    final coords = json['geometry']?['coordinates'] ?? [0, 0];

    // Photon may store city name in different fields
    final cityName =
        props['city'] ??
        props['town'] ??
        props['village'] ??
        props['name'] ??
        '';

    final countryName = props['country'] ?? '';

    return PlaceSuggestion(
      name: cityName,
      country: countryName,
      lat: (coords[1] as num).toDouble(),
      lon: (coords[0] as num).toDouble(),
    );
  }

  factory PlaceSuggestion.fromNominatim(Map<String, dynamic> json) {
    final addressRaw = json["address"];
    final address = addressRaw is Map
        ? addressRaw.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};

    final cityName = _firstNonEmpty(<String>[
      _asString(address["city"]),
      _asString(address["town"]),
      _asString(address["village"]),
      _asString(address["municipality"]),
      _asString(address["county"]),
      _asString(json["name"]),
      _pickDisplayNameHead(_asString(json["display_name"])),
    ]);

    final state = _asString(address["state"]);
    final country = _asString(address["country"]);
    final region = <String>[
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ].join(", ");

    final lat = double.tryParse(_asString(json["lat"])) ?? 0;
    final lon = double.tryParse(_asString(json["lon"])) ?? 0;

    return PlaceSuggestion(name: cityName, country: region, lat: lat, lon: lon);
  }

  static String _asString(dynamic value) => value?.toString().trim() ?? "";

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.isNotEmpty) {
        return value;
      }
    }
    return "";
  }

  static String _pickDisplayNameHead(String displayName) {
    if (displayName.isEmpty) {
      return "";
    }
    return displayName.split(",").first.trim();
  }
}
