// language: dart
import 'dart:ui';
import 'package:astro_tale/App/Model/cart_model.dart';
import 'package:astro_tale/App/Model/product_model.dart';
import 'package:astro_tale/App/controller/Auth_Controller.dart';
import 'package:astro_tale/App/controller/feedback_conroller.dart';
import 'package:astro_tale/App/views/feedback/screen/feedback_screen.dart';
import 'package:astro_tale/App/views/shop/cart/cart_screen.dart';
import 'package:astro_tale/App/views/wishlist/button/wishlist_button.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:astro_tale/services/api_services/api_service.dart';
import 'package:astro_tale/services/api_services/cart_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../core/constants/app_colors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ApiService _apiService = ApiService();
  final CartApi _cartApi = CartApi();

  // typed keys so we can call \`loadFeedbacks()\` safely
  final GlobalKey<FeedbackScreenState> feedbackListKey =
      GlobalKey<FeedbackScreenState>();
  final GlobalKey<FeedbackScreenState> feedbackSheetKey =
      GlobalKey<FeedbackScreenState>();

  ProductModel? product;
  CartModel? cart;
  bool loading = true;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
    _loadCart();
  }

  // ================= FETCH CART =================
  Future<void> _loadCart() async {
    try {
      final fetchedCart = await _cartApi.getCart();
      if (mounted) {
        setState(() {
          cart = fetchedCart;
          cartCount = fetchedCart.items.fold(
            0,
            (sum, item) => sum + item.quantity,
          );
        });
      }
    } catch (e) {
      debugPrint("Cart load error: $e");
    }
  }

  // ================= FETCH PRODUCT =================
  Future<void> _fetchProduct() async {
    try {
      final fetchedProduct = await _apiService.getProductById(
        widget.productId.trim(),
      );

      if (mounted) {
        setState(() {
          product = fetchedProduct;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= ADD TO CART =================
  Future<void> _addToCart() async {
    if (product == null || product!.stock <= 0) return;

    if (!AuthController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add items to cart")),
      );
      return;
    }

    try {
      debugPrint("Adding product to cart: ${product!.id}, quantity: 1");
      await _cartApi.addToCart(product!.id, 1);
      await _loadCart();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to cart")));
      }
    } catch (e) {
      debugPrint("Add to cart failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add to cart: $e")));
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: loading || product == null
          ? const SizedBox()
          : _actionButtons(),

      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(
        context,
        title: 'Product Details',
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartScreen()),
                  ).then((_) => _loadCart());
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.white,
                size: 50,
              ),
            )
          : product == null
          ? _error()
          : _content(),
    );
  }

  Widget _content() {
    return Stack(
      children: [
        _background(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageSlider(),
                const SizedBox(height: 24),

                _infoCard(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;

                          final titleColor = isDark
                              ? Colors.white.withOpacity(0.95)
                              : AppColors.lightTextPrimary;

                          final buttonBg = isDark
                              ? Colors.white.withOpacity(0.10)
                              : AppColors.lightTextPrimary.withOpacity(0.08);

                          final buttonBorder = isDark
                              ? Colors.white24
                              : AppColors.lightTextPrimary.withOpacity(0.25);

                          final iconColor = isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary;

                          final dividerColor = isDark
                              ? Colors.white.withOpacity(0.15)
                              : AppColors.lightTextPrimary.withOpacity(0.25);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Customer Reviews",
                                    style: GoogleFonts.poppins(
                                      color: titleColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _openReviewBottomSheet,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: buttonBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: buttonBorder,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: iconColor,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 2,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: dividerColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: FeedbackScreen(
                    key: feedbackListKey,
                    productId: product!.id,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _background() =>
      Container(decoration: UnifiedDarkUi.screenBackground(Theme.of(context)));

  Widget _imageSlider() {
    final images = product!.images.isNotEmpty
        ? product!.images
        : ["https://via.placeholder.com/400"];

    final PageController controller = PageController(viewportFraction: 0.97);
    int activeIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      height: 320, // total height including dots
      width: double.infinity,
      child: StatefulBuilder(
        builder: (context, setState) {
          controller.addListener(() {
            final newIndex = (controller.page ?? 0).round();
            if (newIndex != activeIndex) {
              setState(() => activeIndex = newIndex);
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image slider
              SizedBox(
                height: 280,
                child: PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    return AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        double value = 1.0;
                        if (controller.position.haveDimensions) {
                          value = controller.page! - i;
                          value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                        }
                        return Center(
                          child: Transform.scale(
                            scale: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 14,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: AspectRatio(
                                    aspectRatio:
                                        4 / 3, // better image proportion
                                    child: Image.network(
                                      images[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.white10,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                        ),
                                      ),
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                progress.expectedTotalBytes !=
                                                    null
                                                ? progress.cumulativeBytesLoaded /
                                                      progress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final isActive = index == activeIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UnifiedDarkUi.cardSurface(theme),
            UnifiedDarkUi.cardSurfaceAlt(theme),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            product!.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white30),
          const SizedBox(height: 12),
          Text(
            product!.description ?? "No description available",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Text(
            "Rs ${product!.price}",
            style: GoogleFonts.poppins(
              color: Colors.amberAccent,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _badges(),
        ],
      ),
    );
  }

  Widget _badges() {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        _badgeChip(product!.astrologyType.name.toUpperCase()),
        _badgeChip(product!.deliveryType.name.toUpperCase()),
        _badgeChip(
          product!.stock > 0 ? "IN STOCK" : "OUT OF STOCK",
          color: product!.stock > 0 ? Colors.greenAccent : Colors.redAccent,
        ),
      ],
    );
  }

  Widget _badgeChip(String label, {Color? color}) {
    final chipColor = color ?? Colors.white; // default white
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(
          alpha: 0.15,
        ), // subtle white/colored background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3), // soft border
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: chipColor, // text color matches chip accent
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButtons() {
    final disabled = product!.stock <= 0;
    bool addedToCart = false; // track if item is added

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wishlist Button
          WishlistButton(productId: product?.id ?? ""),
          SizedBox(width: 10),
          // Add to Cart / Add Another Button
          Expanded(
            child: StatefulBuilder(
              builder: (context, setInnerState) {
                return InkWell(
                  onTap: disabled
                      ? null
                      : () async {
                          await _addToCart();

                          setInnerState(() => addedToCart = true);
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 160,
                    height: 60,
                    decoration: BoxDecoration(
                      color: addedToCart ? Colors.white : Colors.amberAccent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: addedToCart
                            ? Colors.white
                            : (disabled ? Colors.white24 : Colors.amberAccent),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      addedToCart ? "Add Another" : "Add to Cart",
                      style: GoogleFonts.dmSans(
                        color: addedToCart ? Colors.black : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openReviewBottomSheet() {
    double userRating = 0;
    final TextEditingController reviewController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff050B1E).withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Drag Handle
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    /// Title
                    Text(
                      "Rate this product",
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),

                    /// Rating
                    Center(
                      child: RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 36,
                        glow: false,
                        unratedColor: Colors.white24,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star_rounded, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          setModalState(() => userRating = rating);
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// Review Input
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: "Share your experience…",
                        hintStyle: GoogleFonts.dmSans(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// Submit Button / Loader
                    submitting
                        ? Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (userRating == 0 ||
                                    reviewController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please add rating and review",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => submitting = true);

                                try {
                                  await FeedbackController().addFeedback(
                                    productId: product!.id,
                                    rating: userRating,
                                    review: reviewController.text.trim(),
                                  );
                                  if (!context.mounted) return;

                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }

                                  feedbackListKey.currentState?.loadFeedbacks();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Review submitted successfully",
                                      ),
                                    ),
                                  );

                                  _openReviewsListSheet();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Submission failed: $e"),
                                      ),
                                    );

                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  }
                                } finally {
                                  if (mounted) {
                                    setModalState(() => submitting = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Submit Review",
                                style: GoogleFonts.dmSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // glass-style sheet showing the full reviews list
  void _openReviewsListSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    "Reviews",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FeedbackScreen(
                      key: feedbackSheetKey,
                      productId: product!.id,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _error() => Center(
    child: Text(
      "Product not found",
      style: GoogleFonts.poppins(color: Colors.white60),
    ),
  );
}
