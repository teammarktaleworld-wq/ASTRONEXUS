import '../../App/Model/order_model.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class OrderApi {
  final ApiClient _client = ApiClient();

  Future<OrderModel?> placeOrder({
    String? addressId,
    String deliveryType = "physical",
    String paymentMethod = "UPI",
  }) async {
    try {
      final body = {
        if (addressId != null) "addressId": addressId,
        "deliveryType": deliveryType,
        "paymentMethod": paymentMethod,
      };

      final data = await _client.post(ApiEndpoints.placeOrder, body);

      if (data['success'] == true && data['order'] != null) {
        return OrderModel.fromJson(data['order']);
      }
      return null;
    } catch (e) {
      debugPrint("PLACE ORDER ERROR: $e");
      return null;
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final data = await _client.get(ApiEndpoints.ordersMy);
      if (data['success'] == true && data['orders'] != null) {
        return (data['orders'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("GET MY ORDERS ERROR: $e");
      return [];
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final data = await _client.get("${ApiEndpoints.orders}/$orderId");
      if (data['success'] == true && data['order'] != null) {
        return OrderModel.fromJson(data['order']);
      }
      return null;
    } catch (e) {
      debugPrint("GET ORDER BY ID ERROR: $e");
      return null;
    }
  }
}
