import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/api_services/product_suggestion/product_suggestion.dart';
import '../../../Model/suggestion_model.dart';
import '../../shop/product/product_details_screen.dart';

class SuggestionProductList extends StatefulWidget {
  const SuggestionProductList({super.key});

  @override
  State<SuggestionProductList> createState() => _SuggestionProductListState();
}

class _SuggestionProductListState extends State<SuggestionProductList> {
  final ProductSuggestionService _service = ProductSuggestionService();
  List<ProductSuggestion> _products = [];
  bool _loading = true;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;


  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    print("Fetching suggestions from API...");
    final products = await _service.fetchSuggestions();
    print("API returned ${products.length} products");
    for (var p in products) {
      print("Product: ${p.name}, price: ${p.price}");
    }
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_products.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(child: Text("No suggestions available")),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isDark
                ? const LinearGradient(
              colors: [
                Color(0xFF3C467B),
                Color(0xFF636CCB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              colors: [
                Color(0xFFE8ECFF),
                Color(0xFFD6DCFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: const Color(0xFF636CCB).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: const Color(0xFF636CCB).withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFF636CCB).withOpacity(0.2),
            ),
          ),
          child: Text(
            "Product Suggestions",
            style: GoogleFonts.dmSans(
              color: isDark ? Colors.white : const Color(0xFF2C3566),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 300,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _products.length,
            itemBuilder: (_, index) => _buildProductCard(_products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductSuggestion product) {
    final image = product.images.isNotEmpty ? product.images.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.98),
              Colors.white.withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Price tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: image != null
                      ? Image.network(
                          image,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 180,
                          color: Colors.white10,
                          child: const Icon(Icons.image, color: Colors.white30),
                        ),
                ),
                // Price Tag
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "₹${product.price}",
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
            // Name / Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
