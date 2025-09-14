import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill.dart';
import '../models/product.dart';
import '../models/billing_item.dart';

class FirebaseBillProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Bill> _bills = [];
  bool _isLoading = false;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;

  // Add new bill to Firestore
  Future<void> addBill(Bill bill) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add bill to Firestore
      DocumentReference docRef = await _firestore.collection('bills').add({
        'billNumber': bill.billNumber,
        'customerName': bill.customerName,
        'customerPhone': bill.customerPhone,
        'items': bill.items.map((item) => {
          'productName': item.productName,
          'price': item.price,
          'quantity': item.quantity,
          'total': item.total,
        }).toList(),
        'subtotal': bill.subtotal,
        'discount': bill.discount,
        'tax': bill.tax,
        'totalAmount': bill.totalAmount,
        'paymentMethod': bill.paymentMethod,
        'timestamp': bill.timestamp,
      });

      // Update the bill with Firestore document ID
      bill.id = docRef.id;
      _bills.add(bill);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding bill: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all bills from Firestore
  Future<void> loadBills() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('bills')
          .orderBy('timestamp', descending: true)
          .get();

      _bills = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Bill(
          id: doc.id,
          billNumber: data['billNumber'] ?? '',
          customerName: data['customerName'] ?? '',
          customerPhone: data['customerPhone'] ?? '',
          items: (data['items'] as List<dynamic>?)?.map<BillingItem>((item) {
            // Create a temporary product for the billing item
            final product = Product(
              id: item['productId'] ?? '',
              name: item['productName'] ?? '',
              description: '',
              price: (item['price'] ?? 0.0).toDouble(),
              category: '',
              image: '',
            );
            return BillingItem(
              product: product,
              quantity: item['quantity'] ?? 1,
              price: (item['price'] ?? 0.0).toDouble(),
            );
          }).toList() ?? <BillingItem>[],
          subtotal: (data['subtotal'] ?? 0.0).toDouble(),
          discount: (data['discount'] ?? 0.0).toDouble(),
          tax: (data['tax'] ?? 0.0).toDouble(),
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          paymentMethod: data['paymentMethod'] ?? 'Cash',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading bills: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get bill by ID
  Future<Bill?> getBillById(String billId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('bills').doc(billId).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Bill(
          id: doc.id,
          billNumber: data['billNumber'] ?? '',
          customerName: data['customerName'] ?? '',
          customerPhone: data['customerPhone'] ?? '',
          items: (data['items'] as List<dynamic>?)?.map<BillingItem>((item) {
            final product = Product(
              id: item['productId'] ?? '',
              name: item['productName'] ?? '',
              description: '',
              price: (item['price'] ?? 0.0).toDouble(),
              category: '',
              image: '',
            );
            return BillingItem(
              product: product,
              quantity: item['quantity'] ?? 1,
              price: (item['price'] ?? 0.0).toDouble(),
            );
          }).toList() ?? <BillingItem>[],
          subtotal: (data['subtotal'] ?? 0.0).toDouble(),
          discount: (data['discount'] ?? 0.0).toDouble(),
          tax: (data['tax'] ?? 0.0).toDouble(),
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          paymentMethod: data['paymentMethod'] ?? 'Cash',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting bill: $e');
      }
      return null;
    }
  }

  // Get bills by customer phone
  Future<List<Bill>> getBillsByCustomer(String customerPhone) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bills')
          .where('customerPhone', isEqualTo: customerPhone)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Bill(
          id: doc.id,
          billNumber: data['billNumber'] ?? '',
          customerName: data['customerName'] ?? '',
          customerPhone: data['customerPhone'] ?? '',
          items: (data['items'] as List<dynamic>?)?.map<BillingItem>((item) {
            final product = Product(
              id: item['productId'] ?? '',
              name: item['productName'] ?? '',
              description: '',
              price: (item['price'] ?? 0.0).toDouble(),
              category: '',
              image: '',
            );
            return BillingItem(
              product: product,
              quantity: item['quantity'] ?? 1,
              price: (item['price'] ?? 0.0).toDouble(),
            );
          }).toList() ?? <BillingItem>[],
          subtotal: (data['subtotal'] ?? 0.0).toDouble(),
          discount: (data['discount'] ?? 0.0).toDouble(),
          tax: (data['tax'] ?? 0.0).toDouble(),
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          paymentMethod: data['paymentMethod'] ?? 'Cash',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting customer bills: $e');
      }
      return [];
    }
  }

  // Get bills within date range
  Future<List<Bill>> getBillsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bills')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Bill(
          id: doc.id,
          billNumber: data['billNumber'] ?? '',
          customerName: data['customerName'] ?? '',
          customerPhone: data['customerPhone'] ?? '',
          items: (data['items'] as List<dynamic>?)?.map<BillingItem>((item) {
            final product = Product(
              id: item['productId'] ?? '',
              name: item['productName'] ?? '',
              description: '',
              price: (item['price'] ?? 0.0).toDouble(),
              category: '',
              image: '',
            );
            return BillingItem(
              product: product,
              quantity: item['quantity'] ?? 1,
              price: (item['price'] ?? 0.0).toDouble(),
            );
          }).toList() ?? <BillingItem>[],
          subtotal: (data['subtotal'] ?? 0.0).toDouble(),
          discount: (data['discount'] ?? 0.0).toDouble(),
          tax: (data['tax'] ?? 0.0).toDouble(),
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          paymentMethod: data['paymentMethod'] ?? 'Cash',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting bills by date range: $e');
      }
      return [];
    }
  }

  // Delete bill
  Future<void> deleteBill(String billId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('bills').doc(billId).delete();
      _bills.removeWhere((bill) => bill.id == billId);

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting bill: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}