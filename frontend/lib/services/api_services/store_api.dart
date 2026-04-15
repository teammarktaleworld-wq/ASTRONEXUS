import "../../App/Model/category_model.dart";
import "../../App/Model/product_model.dart";
import "feedback_api.dart";
import "api_client.dart";
import "api_endpoints.dart";

class StoreApi {
  final ApiClient _client = ApiClient();

  // ================= PRODUCTS =================

  Future<List<ProductModel>> getProducts({String? categoryId}) async {
    final path = categoryId == null
        ? ApiEndpoints.products
        : "${ApiEndpoints.products}?category=$categoryId";

    final res = await _client.get(path);

    // when API returns array directly
    return (res as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProductById(String productId) async {
    final cleanId = productId.trim();
    if (cleanId.isEmpty) {
      throw Exception("Product ID is required");
    }

    final path = "${ApiEndpoints.products}/$cleanId";
    final res = await _client.get(path);

    /*
      API RESPONSE:
      {
        success: true,
        product: {...}
      }
    */

    if (res == null || res['product'] == null) {
      throw Exception("Product not found");
    }

    return ProductModel.fromJson(Map<String, dynamic>.from(res['product']));
  }

  // ================= CATEGORIES =================

  Future<List<CategoryModel>> getCategories() async {
    final data = await _client.get(ApiEndpoints.categories);
    return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  // ================= REVIEWS =================

  Future<void> addProductReview(
    String productId,
    int rating,
    String comment,
  ) async {
    await FeedbackApi().submitFeedback(
      productId: productId,
      rating: rating.toDouble(),
      review: comment,
    );
  }
}
