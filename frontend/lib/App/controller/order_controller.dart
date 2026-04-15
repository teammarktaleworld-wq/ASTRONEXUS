import 'package:flutter/material.dart';
import '../../services/api_services/api_service.dart';
import '../Model/order_model.dart';

class OrderController extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<OrderModel> orders = [];
  bool loading = false;

  /// Place order with addressId and payment method
  Future<bool> placeOrder({
    required String addressId,
    String deliveryType = "physical",
    String paymentMethod = "UPI",
  }) async {
    try {
      final order = await _api.placeOrder(
        addressId: addressId,
        deliveryType: deliveryType,
        paymentMethod: paymentMethod,
      );
      if (order != null) {
        return true; // success
      }
      return false; // failed
    } catch (e) {
      print("OrderController.placeOrder ERROR: $e");
      return false;
    }
  }

  /// Fetch user's order history
  Future<void> fetchMyOrders() async {
    loading = true;
    notifyListeners();

    try {
      orders = await _api.getMyOrders();
    } catch (e) {
      print("OrderController.fetchMyOrders ERROR: $e");
      orders = [];
    }

    loading = false;
    notifyListeners();
  }

  /// Get single order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
