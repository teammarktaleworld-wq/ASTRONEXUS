import 'dart:async';

import 'package:astro_tale/App/controller/Auth_Controller.dart';
import 'package:astro_tale/App/views/shop/product/product_details_screen.dart';
import 'package:astro_tale/App/views/shop/widgets/search_field.dart';
import 'package:astro_tale/App/views/wishlist/screen/wishlist_screen.dart';
import 'package:astro_tale/core/localization/app_localizations.dart';
import 'package:astro_tale/core/widgets/animated_app_background.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:astro_tale/util/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:astro_tale/App/views/shop/widgets/category_chip.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart'; // <-- skeleton import

import '../../../services/api_services/cart_api.dart';
import '../../../services/api_services/store_api.dart';
import '../../../services/api_services/wishlist_service.dart';
import 'package:astro_tale/App/Model/category_model.dart';
import 'package:astro_tale/App/Model/product_model.dart';

import 'cart/cart_screen.dart';
import 'orders/my_orders_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreApi _storeApi = StoreApi();
  final CartApi _cartApi = CartApi();
  final TextEditingController _searchController = TextEditingController();

  bool isSearching = false;
  bool loading = true;
  int cartCount = 0;
  int wishlistCount = 0;

  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  List<CategoryModel> categories = [];

  int selectedCategoryIndex = 0;

  // ================= BANNER ANIMATION =================
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  final List<String> banners = [
    AppConstant.banner_shop1,
    AppConstant.banner_shop2,
    AppConstant.banner_shop1,
  ];

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    _syncBadges();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBanner = (_currentBanner + 1) % banners.length;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ================= FETCH =================

  Future<void> _fetchStoreData() async {
    setState(() => loading = true);
    try {
      final fetchedCategories = await _storeApi.getCategories();

      categories = [
        CategoryModel(
          id: "",
          name: "All",
          slug: "all",
          isActive: true,
          order: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ...fetchedCategories,
      ];

      products = await _storeApi.getProducts();
    } catch (e) {
      debugPrint("Store fetch error: $e");
    }
    if (mounted) setState(() => loading = false);
    _syncBadges();
  }

  Future<void> _fetchProductsByCategory(String? categoryId) async {
    setState(() => loading = true);
    try {
      products = await _storeApi.getProducts(categoryId: categoryId);
      filteredProducts.clear();
      isSearching = false;
      _searchController.clear();
    } catch (e) {
      debugPrint("Category fetch error: $e");
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _syncBadges() async {
    if (!AuthController.isLoggedIn || AuthController.token.isEmpty) {
      if (mounted) {
        setState(() {
          cartCount = 0;
          wishlistCount = 0;
        });
      }
      return;
    }

    int resolvedCart = cartCount;
    int resolvedWishlist = wishlistCount;

    try {
      final cart = await _cartApi.getCart();
      resolvedCart = cart.items.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
    } catch (e) {
      debugPrint("Badge cart sync error: $e");
    }

    try {
      final wishlist = await WishlistService(
        token: AuthController.token,
      ).getWishlist();
      resolvedWishlist = wishlist.products.length;
    } catch (e) {
      debugPrint("Badge wishlist sync error: $e");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      cartCount = resolvedCart;
      wishlistCount = resolvedWishlist;
    });
  }

  // ================= SEARCH =================

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        isSearching = false;
        filteredProducts.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
      filteredProducts = products
          .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(
        context,
        title: context.l10n.tr("shop"),
        centerTitle: false,
        actions: [
          _iconWithBadge(
            icon: Icons.favorite_border,
            count: wishlistCount,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WishlistScreen()),
              );
              _syncBadges();
            },
          ),
          _iconWithBadge(
            icon: Icons.shopping_cart_outlined,
            count: cartCount,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
              _syncBadges();
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyOrdersScreen()),
              );
              _syncBadges();
            },
          ),
        ],
      ),
      body: AnimatedAppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                loading
                    ? SkeletonItem(
                        child: SkeletonParagraph(
                          style: SkeletonParagraphStyle(
                            lines: 1,
                            spacing: 12,
                            lineStyle: SkeletonLineStyle(
                              height: 160,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      )
                    : _bannerSlider(),
                const SizedBox(height: 16),
                SearchField(
                  controller: _searchController,
                  isSearching: isSearching,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    _onSearchChanged("");
                  },
                ),
                const SizedBox(height: 16),
                loading ? _categorySkeleton() : _categoryChips(),
                const SizedBox(height: 20),
                _productGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconWithBadge({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  "$count",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ================= BANNER UI =================

  Widget _bannerSlider() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: banners.length,
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(banners[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  // ================= CATEGORY SKELETON =================

  Widget _categorySkeleton() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => SkeletonItem(
          child: SkeletonLine(
            style: SkeletonLineStyle(
              width: 80,
              height: 40,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  // ================= CATEGORY =================

  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              label: category.name,
              isSelected: index == selectedCategoryIndex,
              onTap: () {
                setState(() => selectedCategoryIndex = index);
                final id = category.id.isEmpty ? null : category.id;
                _fetchProductsByCategory(id);
              },
            ),
          );
        },
      ),
    );
  }

  // ================= PRODUCTS =================

  // ================= PRODUCTS =================

  Widget _productGrid() {
    final list = isSearching ? filteredProducts : products;
    final theme = Theme.of(context);
    final cardStart = UnifiedDarkUi.cardSurface(theme);
    final cardEnd = UnifiedDarkUi.cardSurfaceAlt(theme);

    if (loading) {
      // Show skeleton shimmer cards
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => SkeletonItem(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 180,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 10),
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 16,
                  width: 120,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 14,
                  width: 60,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No products found",
            style: GoogleFonts.dmSans(
              color: UnifiedDarkUi.mutedOnCard(theme),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: list.length,
      itemBuilder: (_, index) {
        final product = list[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailsScreen(productId: product.id.trim()),
                ),
              );
              _syncBadges();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [cardStart, cardEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with rounded corners and overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          product.images.isNotEmpty
                              ? product.images.first
                              : "https://via.placeholder.com/200",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Rs ${product.price.toStringAsFixed(2)}",
                            style: GoogleFonts.dmSans(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      product.name,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
