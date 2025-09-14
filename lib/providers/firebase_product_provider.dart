import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class FirebaseProductProvider extends ChangeNotifier {
  List<String> _categories = ['All'];

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<String> get categories => _categories;
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;

  FirebaseProductProvider() {
    _initializeProducts();
  }

  // Initialize products from Firebase
  Future<void> _initializeProducts() async {
    await loadProducts();
    await loadCategories();
  }

  // Load categories from products
  Future<void> loadCategories() async {
    try {
      Set<String> categorySet = {'All'};
      
      // Extract unique categories from products
      for (Product product in _products) {
        if (product.category.isNotEmpty) {
          categorySet.add(product.category);
        }
      }
      
      _categories = categorySet.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // Load products from Firebase
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await FirebaseService.getProducts();
      
      // Products loaded from Firebase (may be empty)
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }



  // Add new product
  Future<void> addProduct(Product product) async {
    try {
      await FirebaseService.addProduct(product);
      await loadProducts(); // Refresh the list
      await loadCategories(); // Refresh categories in case new category was added
    } catch (e) {
      _error = 'Failed to add product: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update existing product
  Future<void> updateProduct(Product product) async {
    try {
      await FirebaseService.updateProduct(product.id, product);
      await loadProducts(); // Refresh the list
    } catch (e) {
      _error = 'Failed to update product: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseService.deleteProduct(productId);
      await loadProducts(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete product: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update product stock
  Future<void> updateProductStock(String productId, int newQuantity) async {
    try {
      await FirebaseService.updateProductStock(productId, newQuantity);
      
      // Update local state
      int index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        Product updatedProduct = Product(
          id: _products[index].id,
          name: _products[index].name,
          description: _products[index].description,
          price: _products[index].price,
          category: _products[index].category,
          image: _products[index].image,
          isAvailable: _products[index].isAvailable,
          stock: newQuantity,
        );
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Reduce stock for multiple products when bill is processed
  Future<void> reduceStockForBillingItems(List<dynamic> billingItems) async {
    try {
      for (var item in billingItems) {
        // Find the current product
        int index = _products.indexWhere((p) => p.id == item.product.id);
        if (index != -1) {
          Product currentProduct = _products[index];
          int newStock = currentProduct.stock - (item.quantity as int);
          
          // Ensure stock doesn't go below 0
          if (newStock < 0) {
            throw Exception('Insufficient stock for ${currentProduct.name}. Available: ${currentProduct.stock}, Required: ${item.quantity}');
          }
          
          // Update stock in Firebase and local state
          await updateProductStock(currentProduct.id, newStock);
        }
      }
    } catch (e) {
      _error = 'Failed to reduce stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == category).toList();
  }

  // Get filtered products by category and search text
  List<Product> getFilteredProducts(String category, String searchText) {
    List<Product> filtered = _products;
    
    // Filter by category
    if (category != 'All') {
      filtered = filtered.where((product) => 
        product.category == category).toList();
    }
    
    // Filter by search
    if (searchText.isNotEmpty) {
      filtered = filtered.where((product) =>
        product.name.toLowerCase().contains(searchText.toLowerCase()) ||
        product.description.toLowerCase().contains(searchText.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Listen to real-time product updates
  void listenToProducts() {
    FirebaseService.getProductsStream().listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  // Generate unique product ID
  String generateProductId() {
    return 'prod_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Add new category
  bool addCategory(String category) {
    if (!_categories.contains(category) && category.isNotEmpty) {
      _categories.add(category);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Remove category
  void removeCategory(String category) {
    if (_categories.contains(category) && category != 'All') {
      _categories.remove(category);
      notifyListeners();
    }
  }
}