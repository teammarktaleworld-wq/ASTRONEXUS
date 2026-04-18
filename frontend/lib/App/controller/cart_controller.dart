import 'package:flutter/material.dart';
import '../../services/api_services/api_service.dart';
import '../Model/cart_model.dart';
import '../controller/Auth_Controller.dart';

class CartController extends ChangeNotifier {
  final ApiService _api = ApiService();

  CartModel? cart;
  bool loading = false;
  String? errorMessage;

  /// =========================
  /// FETCH CART
  /// =========================
  Future<void> fetchCart() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      cart = await _api.getCart();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Fetch cart failed: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// ADD TO CART
  /// =========================
  Future<void> addToCart(String productId, int quantity) async {
    if (!AuthController.isLoggedIn) {
      debugPrint("User not logged in");
      errorMessage = "Please login first";
      notifyListeners();
      return;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _api.addToCart(productId, quantity);
      await fetchCart(); // refresh cart
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Add to cart failed: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// UPDATE QUANTITY
  /// =========================
  Future<void> updateQuantity(String productId, int quantity) async {
    if (!AuthController.isLoggedIn) return;

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _api.updateCartItem(productId, quantity);
      await fetchCart();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Update cart item failed: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// REMOVE ITEM
  /// =========================
  Future<void> removeItem(String productId) async {
    if (!AuthController.isLoggedIn) return;

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _api.removeCartItem(productId);
      await fetchCart();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Remove cart item failed: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// GET TOTAL ITEMS
  /// =========================
  int get totalItems {
    if (cart == null) return 0;
    return cart!.items.fold(0, (sum, i) => sum + i.quantity);
  }

  /// =========================
  /// GET CART TOTAL
  /// =========================
  double get subtotal => cart?.subtotal ?? 0.0;

  double get discount => cart?.discount ?? 0.0;

  double get total => cart?.total ?? 0.0;
}
