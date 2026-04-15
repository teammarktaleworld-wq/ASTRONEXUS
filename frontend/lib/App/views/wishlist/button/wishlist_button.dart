import 'package:flutter/material.dart';
import 'package:astro_tale/App/controller/Auth_Controller.dart';
import '../../../../services/api_services/wishlist_service.dart';

class WishlistButton extends StatefulWidget {
  final String productId;

  const WishlistButton({super.key, required this.productId});

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  late WishlistService _service;
  bool isWishlisted = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _service = WishlistService(token: AuthController.token);
    _loadWishlistStatus();
  }

  /// Load initial status from server
  Future<void> _loadWishlistStatus() async {
    setState(() => loading = true);
    try {
      final wishlist = await _service.getWishlist();
      // Check if the current product is in the wishlist
      final exists = wishlist.products.any((p) => p.id == widget.productId);
      if (mounted) {
        setState(() => isWishlisted = exists);
      }
    } catch (_) {
      // ignore errors silently
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Toggle wishlist
  Future<void> _toggleWishlist() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      if (isWishlisted) {
        await _service.removeProduct(widget.productId);
      } else {
        await _service.addProduct(widget.productId);
      }
      if (mounted) setState(() => isWishlisted = !isWishlisted);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update wishlist")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : _toggleWishlist,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isWishlisted ? Colors.redAccent : Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 28,
              ),
      ),
    );
  }
}
