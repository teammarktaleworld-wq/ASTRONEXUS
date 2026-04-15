import '../../App/Model/payment_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class PaymentApi {
  final ApiClient _client = ApiClient();

  Future<PaymentModel> createPayment(double amount) async {
    final data = await _client.post(ApiEndpoints.createPayment, {
      "amount": amount,
    });
    return PaymentModel.fromJson(data);
  }

  Future<bool> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    final data = await _client.post(ApiEndpoints.verifyPayment, {
      "paymentId": paymentId,
      "transactionId": transactionId,
    });
    return data["success"] == true;
  }
}
