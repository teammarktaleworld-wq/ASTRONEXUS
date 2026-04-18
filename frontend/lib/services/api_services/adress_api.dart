import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../App/Model/address_model.dart';
import 'api_endpoints.dart';

class AddressApi {
  final String _baseUrl = ApiEndpoints.baseUrl;

  // ---------------- GET USER ADDRESSES ----------------
  Future<List<Address>> getUserAddresses({required String token}) async {
    final url = Uri.parse("$_baseUrl${ApiEndpoints.addresses}");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((addr) => Address.fromJson(addr)).toList();
    } else {
      throw Exception("Failed to load addresses");
    }
  }

  // ---------------- ADD ADDRESS ----------------
  Future<Address> addAddress({
    required String token,
    required Address address,
  }) async {
    final url = Uri.parse("$_baseUrl${ApiEndpoints.addAddress}");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "fullName": address.fullName,
        "phone": address.phone,
        "street": address.street,
        "city": address.city,
        "state": address.state,
        "country": address.country,
        "postalCode": address.postalCode,
        "isDefault": address.isDefault,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Address.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to add address");
    }
  }

  // ---------------- UPDATE ADDRESS ----------------
  Future<Address> updateAddress({
    required String token,
    required Address address,
  }) async {
    final url = Uri.parse("$_baseUrl${ApiEndpoints.addresses}/${address.id}");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "fullName": address.fullName,
        "phone": address.phone,
        "street": address.street,
        "city": address.city,
        "state": address.state,
        "country": address.country,
        "postalCode": address.postalCode,
        "isDefault": address.isDefault,
      }),
    );

    if (response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update address");
    }
  }

  // ---------------- DELETE ADDRESS ----------------
  Future<void> deleteAddress({
    required String token,
    required String addressId,
  }) async {
    final url = Uri.parse("$_baseUrl${ApiEndpoints.addresses}/$addressId");
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete address");
    }
  }
}
