import 'package:flutter/material.dart';
import '../../services/api_services/api_service.dart';
import '../Model/payment_model.dart';

class PaymentController extends ChangeNotifier {
  final ApiService _api = ApiService();

  PaymentModel? payment;
  bool loading = false;

  /// Step 1: Create payment (before opening gateway)
  Future<PaymentModel> createPayment(double amount) async {
    loading = true;
    notifyListeners();

    payment = await _api.createPayment(amount);

    loading = false;
    notifyListeners();

    return payment!;
  }

  /// Step 2: Verify payment (after gateway success)
  Future<bool> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    return await _api.verifyPayment(
      paymentId: paymentId,
      transactionId: transactionId,
    );
  }
}
