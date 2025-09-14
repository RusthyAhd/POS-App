import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/customer.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  static const String _productsCollection = 'products';
  static const String _customersCollection = 'customers';
  static const String _stockUpdatesCollection = 'stock_updates';
  static const String _billsCollection = 'bills';

  // Product Services
  static Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(_productsCollection).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  static Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection(_productsCollection).add(product.toFirestore());
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  static Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore.collection(_productsCollection).doc(productId).update(product.toFirestore());
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_productsCollection).doc(productId).delete();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  static Future<void> updateProductStock(String productId, int newQuantity) async {
    try {
      await _firestore.collection(_productsCollection).doc(productId).update({
        'quantity': newQuantity,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating product stock: $e');
      rethrow;
    }
  }

  // Customer Services
  static Future<List<Customer>> getCustomers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(_customersCollection).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Customer.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting customers: $e');
      return [];
    }
  }

  static Future<void> addCustomer(Customer customer) async {
    try {
      await _firestore.collection(_customersCollection).add(customer.toFirestore());
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  static Future<void> updateCustomer(String customerId, Customer customer) async {
    try {
      await _firestore.collection(_customersCollection).doc(customerId).update(customer.toFirestore());
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }

  static Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection(_customersCollection).doc(customerId).delete();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      rethrow;
    }
  }

  // Stock Update Services
  static Future<void> addStockUpdate(Map<String, dynamic> stockUpdate) async {
    try {
      await _firestore.collection(_stockUpdatesCollection).add({
        ...stockUpdate,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding stock update: $e');
      rethrow;
    }
  }

  // Bill Services
  static Future<void> saveBill(Map<String, dynamic> billData) async {
    try {
      await _firestore.collection(_billsCollection).add({
        ...billData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving bill: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getBills() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_billsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting bills: $e');
      return [];
    }
  }

  // Real-time listeners
  static Stream<List<Product>> getProductsStream() {
    return _firestore.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Product.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  static Stream<List<Customer>> getCustomersStream() {
    return _firestore.collection(_customersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Customer.fromFirestore(data, doc.id);
      }).toList();
    });
  }
}
