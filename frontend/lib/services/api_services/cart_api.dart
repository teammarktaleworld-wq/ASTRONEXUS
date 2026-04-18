import "../../App/Model/cart_model.dart";
import "api_client.dart";
import "api_endpoints.dart";

class CartApi {
  final ApiClient _client = ApiClient();

  Future<CartModel> getCart() async {
    final data = await _client.get(ApiEndpoints.cart);

    if (data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to load cart");
    }

    final cartJson = data["cart"] ?? <String, dynamic>{"items": <dynamic>[]};
    return CartModel.fromJson(Map<String, dynamic>.from(cartJson));
  }

  Future<void> addToCart(String productId, int quantity) async {
    final response = await _client.post(
      ApiEndpoints.addToCart,
      <String, dynamic>{"productId": productId, "quantity": quantity},
    );

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Add to cart failed");
    }
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    final response = await _client.post(
      ApiEndpoints.updateCart,
      <String, dynamic>{"productId": productId, "quantity": quantity},
    );

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Update cart failed");
    }
  }

  Future<void> removeCartItem(String productId) async {
    final response = await _client.delete(
      "${ApiEndpoints.removeCart}/$productId",
    );

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Remove cart failed");
    }
  }
}
