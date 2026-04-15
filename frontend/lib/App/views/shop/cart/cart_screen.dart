import 'package:astro_tale/App/controller/Auth_Controller.dart';
import 'package:astro_tale/App/Model/address_model.dart';
import 'package:astro_tale/App/Model/cart_model.dart';
import 'package:astro_tale/App/views/shop/checkout/address_selector.dart';
import 'package:astro_tale/App/views/shop/checkout/checkout_screen.dart';
import 'package:astro_tale/App/views/shop/widgets/discount_widgets.dart';
import 'package:astro_tale/App/views/shop/cart/cart_summary.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:astro_tale/services/api_services/cart_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartApi _cartApi = CartApi();

  CartModel? cart;
  bool loading = true;

  double discountedTotal = 0.0;
  bool discountApplied = false;
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => loading = true);
    try {
      cart = await _cartApi.getCart();
    } catch (e) {
      debugPrint("Cart load error: $e");
    }
    setState(() => loading = false);
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    if (quantity < 1) return;

    final index = cart!.items.indexWhere((item) => item.productId == productId);

    if (index != -1) {
      setState(() {
        cart!.items[index] = CartItemModel(
          productId: cart!.items[index].productId,
          name: cart!.items[index].name,
          price: cart!.items[index].price,
          image: cart!.items[index].image,
          quantity: quantity,
        );
      });
    }

    try {
      await _cartApi.updateCartItem(productId, quantity);
      await _loadCart();
    } catch (e) {
      debugPrint("Update quantity failed: $e");
    }
  }

  Future<void> _removeItem(String productId) async {
    await _cartApi.removeCartItem(productId);
    await _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(context, title: "Your Cart"),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: loading
                ? _shimmerLoader()
                : cart == null || cart!.items.isEmpty
                ? const Center(
                    child: Text(
                      "Your cart is empty",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cart!.items.length,
                            itemBuilder: (context, index) {
                              return _cartItemCard(cart!.items[index]);
                            },
                          ),
                        ),
                        ApplyDiscountWidget(
                          cartTotal: cart!.subtotal.toDouble(),
                          onDiscountApplied: (finalAmount) {
                            setState(() {
                              discountedTotal = finalAmount;
                              discountApplied = true;
                            });
                          },
                        ),

                        const SizedBox(height: 12),
                        CartSummary(
                          subtotal: cart!.subtotal.toDouble(),
                          discount: discountApplied
                              ? cart!.subtotal.toDouble() - discountedTotal
                              : 0.0,
                          total: discountApplied
                              ? discountedTotal
                              : cart!.subtotal.toDouble(),
                          onCheckout: () async {
                            final Address? selectedAddress =
                                await Navigator.push<Address>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddressSelector(
                                      token: AuthController.token,
                                    ),
                                  ),
                                );

                            if (!context.mounted) return;
                            if (selectedAddress == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  cart: cart!,
                                  userToken: AuthController.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ================= BACKGROUND =================

  Widget _background() {
    return Container(
      decoration: UnifiedDarkUi.screenBackground(Theme.of(context)),
    );
  }

  // ================= SHIMMER LOADER =================

  Widget _shimmerLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (_, __) => _shimmerCartItem(),
      ),
    );
  }

  Widget _shimmerCartItem() {
    return Shimmer.fromColors(
      baseColor: Colors.white12,
      highlightColor: Colors.white24,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  const SizedBox(height: 14, width: 100),
                  const SizedBox(height: 12),
                  const SizedBox(height: 28, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CART ITEM =================

  Widget _cartItemCard(CartItemModel item) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              UnifiedDarkUi.cardSurface(theme),
              UnifiedDarkUi.cardSurfaceAlt(theme),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
          border: Border.all(
            color: UnifiedDarkUi.cardBorder(theme),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(item.image),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rs ${item.price.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _quantityControls(item),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _removeItem(item.productId),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url.isNotEmpty ? url : "https://via.placeholder.com/80",
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _quantityControls(CartItemModel item) {
    return Row(
      children: [
        _iconButton(
          Icons.remove,
          () => _updateQuantity(item.productId, item.quantity - 1),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.quantity.toString(),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        _iconButton(
          Icons.add,
          () => _updateQuantity(item.productId, item.quantity + 1),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
