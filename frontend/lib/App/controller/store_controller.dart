import 'package:flutter/material.dart';
import '../../services/api_services/api_service.dart';
import '../Model/category_model.dart';
import '../Model/product_model.dart';

class StoreController extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CategoryModel> categories = [];
  List<ProductModel> products = [];

  String? selectedCategoryId;
  bool loading = false;

  /// Initial load → ALL categories + ALL products
  Future<void> initStore() async {
    loading = true;
    notifyListeners();

    categories = await _api.getCategories();
    products = await _api.getProducts();

    loading = false;
    notifyListeners();
  }

  /// Category click → filtered products
  Future<void> selectCategory(String? categoryId) async {
    selectedCategoryId = categoryId;
    loading = true;
    notifyListeners();

    products = await _api.getProducts(categoryId: categoryId);

    loading = false;
    notifyListeners();
  }
}
