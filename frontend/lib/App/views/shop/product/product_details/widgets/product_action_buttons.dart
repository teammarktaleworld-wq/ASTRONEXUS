import 'package:flutter/material.dart';
import '../../../../../../services/api_services/api_service.dart';
import '../../../../../Model/product_model.dart';

class ProductActionButtons extends StatelessWidget {
  final ProductModel product;
  const ProductActionButtons({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    final disabled = product.stock <= 0;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: disabled ? null : () => api.addToCart(product.id, 1),
            child: const Text("Add to Cart"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: disabled ? null : () {},
            child: const Text("Buy Now"),
          ),
        ),
      ],
    );
  }
}
