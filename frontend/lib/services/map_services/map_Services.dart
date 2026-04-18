import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getCoordinates(String place) async {
  final String apiKey = "AIzaSyA_kcRUigM8lLpA_89pzq7axWZbSzm1Jcc";
  final url =
      "https://maps.googleapis.com/maps/api/geocode/json?address=$place&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  final data = jsonDecode(response.body);

  if (data["status"] == "OK") {
    final location = data["results"][0]["geometry"]["location"];

    return {
      "lat": location["lat"],
      "lng": location["lng"],
      "timezone": data["results"][0]["address_components"],
    };
  } else {
    throw Exception("Location not found");
  }
}
