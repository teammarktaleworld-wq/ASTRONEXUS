import 'package:shared_preferences/shared_preferences.dart';
import 'cart_api.dart';
import '../../App/Model/address_model.dart';
import 'adress_api.dart';
import 'store_api.dart';
import 'order_api.dart';
import 'payment_api.dart';

class ApiService {
  final StoreApi _store = StoreApi();
  final CartApi _cart = CartApi();
  final OrderApi _order = OrderApi();
  final PaymentApi _payment = PaymentApi();
  final AddressApi _address = AddressApi();

  /* ================= AUTH TOKEN ================= */

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }

  /* ================= STORE ================= */

  Future getCategories() => _store.getCategories();

  Future getProducts({String? categoryId}) =>
      _store.getProducts(categoryId: categoryId);

  Future getProductById(String productId) => _store.getProductById(productId);

  /* ================= CART ================= */

  Future getCart() => _cart.getCart();

  Future addToCart(String productId, int qty) =>
      _cart.addToCart(productId, qty);

  Future updateCartItem(String productId, int qty) =>
      _cart.updateCartItem(productId, qty);

  Future removeCartItem(String productId) => _cart.removeCartItem(productId);

  /* ================= ORDERS ================= */

  Future placeOrder({
    String? addressId,
    String paymentMethod = "UPI",
    required String deliveryType,
  }) => _order.placeOrder(
    addressId: addressId,
    paymentMethod: paymentMethod,
    deliveryType: deliveryType,
  );

  Future getMyOrders() => _order.getMyOrders();

  Future getOrderById(String orderId) => _order.getOrderById(orderId);

  /* ================= PAYMENT ================= */

  Future createPayment(double amount) => _payment.createPayment(amount);

  Future verifyPayment({
    required String paymentId,
    required String transactionId,
  }) => _payment.verifyPayment(
    paymentId: paymentId,
    transactionId: transactionId,
  );

  /* ================= ADDRESS ================= */

  Future<List<Address>> getUserAddresses({required String token}) =>
      _address.getUserAddresses(token: token);

  Future addAddress({required String token, required Address address}) =>
      _address.addAddress(token: token, address: address);

  Future updateAddress({required String token, required Address address}) =>
      _address.updateAddress(token: token, address: address);

  Future deleteAddress({required String token, required String addressId}) =>
      _address.deleteAddress(token: token, addressId: addressId);
}
