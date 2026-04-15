import "dart:convert";

import "package:astro_tale/App/controller/Auth_Controller.dart";
import "package:astro_tale/core/constants/app_constants.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

import "api_endpoints.dart";

class ApiClient {
  Future<dynamic> get(String path) async {
    final response = await http
        .get(_buildUri(path), headers: _headers())
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(_buildUri(path), headers: _headers(), body: jsonEncode(body))
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http
        .put(_buildUri(path), headers: _headers(), body: jsonEncode(body))
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) async {
    final response = await http
        .delete(
          _buildUri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith("/") ? path : "/$path";
    return Uri.parse("${ApiEndpoints.baseUrl}$normalizedPath");
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (AuthController.token.isNotEmpty) {
      headers["Authorization"] = "Bearer ${AuthController.token}";
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final dynamic data = _decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data is Map<String, dynamic>
        ? data["message"]?.toString() ?? "API Error"
        : "API Error";

    debugPrint("API error ${response.statusCode}: $message");
    throw Exception(message);
  }

  dynamic _decode(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{"raw": body};
    }
  }
}
