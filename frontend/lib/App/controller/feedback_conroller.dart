import '../../services/api_services/feedback_api.dart';

class FeedbackController {
  final FeedbackApi _api = FeedbackApi();

  /// Fetch feedbacks for a product
  Future<List<dynamic>> fetchFeedbacks(String productId) async {
    return await _api.getProductFeedback(productId);
  }

  /// Submit feedback for a product
  Future<void> addFeedback({
    required String productId,
    required double rating,
    required String review,
  }) async {
    await _api.submitFeedback(
      productId: productId,
      rating: rating,
      review: review,
    );
  }
}
