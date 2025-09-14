import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<String> _categories = [
    'All',
    'Anchor',
    'Kotmalee',
    'Sunsilk',
    'Baby Cheramy',
    'Beverages',
    'Snacks',
    'Rice & Grains',
  ];

  final List<Product> _products = [
    // Anchor Products
    Product(
      id: '1',
      name: 'Anchor Milk Powder 400g',
      description: 'Premium quality full cream milk powder from New Zealand',
      price: 850.00,
      category: 'Anchor',
      image: 'anchor_milk',
      stock: 45,
    ),
    Product(
      id: '2',
      name: 'Anchor Cheese Slices 200g',
      description: 'Processed cheese slices perfect for sandwiches',
      price: 520.00,
      category: 'Anchor',
      image: 'anchor_cheese',
      stock: 30,
    ),
    Product(
      id: '3',
      name: 'Anchor Butter 200g',
      description: 'Pure New Zealand butter for cooking and baking',
      price: 680.00,
      category: 'Anchor',
      image: 'anchor_butter',
      stock: 25,
    ),
    
    // Kotmalee Products
    Product(
      id: '4',
      name: 'Kotmalee Black Tea 200g',
      description: 'Premium Ceylon black tea from highland estates',
      price: 320.00,
      category: 'Kotmalee',
      image: 'kotmalee_tea',
      stock: 60,
    ),
    Product(
      id: '5',
      name: 'Kotmalee Green Tea 100g',
      description: 'Natural green tea with antioxidants',
      price: 450.00,
      category: 'Kotmalee',
      image: 'kotmalee_green',
      stock: 35,
    ),
    
    // Sunsilk Products
    Product(
      id: '6',
      name: 'Sunsilk Shampoo 350ml',
      description: 'Nourishing shampoo for soft and silky hair',
      price: 480.00,
      category: 'Sunsilk',
      image: 'sunsilk_shampoo',
      stock: 40,
    ),
    Product(
      id: '7',
      name: 'Sunsilk Conditioner 200ml',
      description: 'Hair conditioner for smooth and manageable hair',
      price: 420.00,
      category: 'Sunsilk',
      image: 'sunsilk_conditioner',
      stock: 28,
    ),
    
    // Baby Cheramy Products
    Product(
      id: '8',
      name: 'Baby Cheramy Soap 75g',
      description: 'Gentle baby soap with natural ingredients',
      price: 180.00,
      category: 'Baby Cheramy',
      image: 'baby_soap',
      stock: 55,
    ),
    Product(
      id: '9',
      name: 'Baby Cheramy Lotion 200ml',
      description: 'Moisturizing baby lotion for soft skin',
      price: 350.00,
      category: 'Baby Cheramy',
      image: 'baby_lotion',
      stock: 32,
    ),
    
    // Beverages
    Product(
      id: '10',
      name: 'Coca Cola 330ml',
      description: 'Refreshing carbonated soft drink',
      price: 120.00,
      category: 'Beverages',
      image: 'coca_cola',
      stock: 80,
    ),
    Product(
      id: '11',
      name: 'Sprite 330ml',
      description: 'Lemon-lime flavored carbonated drink',
      price: 120.00,
      category: 'Beverages',
      image: 'sprite',
      stock: 75,
    ),
    
    // Snacks
    Product(
      id: '12',
      name: 'Maliban Krackjack 100g',
      description: 'Crispy coconut biscuits with chocolate',
      price: 180.00,
      category: 'Snacks',
      image: 'krackjack',
      stock: 65,
    ),
    Product(
      id: '13',
      name: 'Munchee Tikiri 200g',
      description: 'Traditional Sri Lankan coconut biscuits',
      price: 220.00,
      category: 'Snacks',
      image: 'tikiri',
      stock: 50,
    ),
    
    // Rice & Grains
    Product(
      id: '14',
      name: 'Keeri Samba Rice 1kg',
      description: 'Premium quality Sri Lankan rice',
      price: 280.00,
      category: 'Rice & Grains',
      image: 'keeri_samba',
      stock: 120,
    ),
    Product(
      id: '15',
      name: 'Red Rice 1kg',
      description: 'Healthy red rice rich in nutrients',
      price: 320.00,
      category: 'Rice & Grains',
      image: 'red_rice',
      stock: 90,
    ),
  ];

  List<String> get categories => _categories;
  List<Product> get products => _products;

  // Add new category
  bool addCategory(String categoryName) {
    String trimmedName = categoryName.trim();
    if (trimmedName.isEmpty || _categories.contains(trimmedName)) {
      return false;
    }
    _categories.add(trimmedName);
    notifyListeners();
    return true;
  }

  // Add new product
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  // Update product stock
  void updateProductStock(String productId, int newStock) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = Product(
        id: _products[index].id,
        name: _products[index].name,
        description: _products[index].description,
        price: _products[index].price,
        category: _products[index].category,
        image: _products[index].image,
        stock: newStock,
      );
      notifyListeners();
    }
  }

  // Delete product
  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
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

  // Generate unique product ID
  String generateProductId() {
    return 'PROD${DateTime.now().millisecondsSinceEpoch}';
  }
}