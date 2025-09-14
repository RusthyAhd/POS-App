import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bill.dart';

class LocalBillProvider with ChangeNotifier {
  List<Bill> _bills = [];
  bool _isLoading = false;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;

  // Load bills from local storage
  Future<void> loadBills() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final billsJson = prefs.getStringList('bills') ?? [];
      
      _bills = billsJson.map((jsonString) {
        final Map<String, dynamic> billMap = json.decode(jsonString);
        return Bill.fromJson(billMap);
      }).toList();
      
      _bills.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading bills: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new bill
  Future<void> addBill(Bill bill) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _bills.insert(0, bill);
      
      final billsJson = _bills.map((bill) => json.encode(bill.toJson())).toList();
      await prefs.setStringList('bills', billsJson);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding bill: $e');
      }
      rethrow;
    }
  }

  // Get bill by ID
  Bill? getBillById(String id) {
    try {
      return _bills.firstWhere((bill) => bill.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete bill
  Future<void> deleteBill(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _bills.removeWhere((bill) => bill.id == id);
      
      final billsJson = _bills.map((bill) => json.encode(bill.toJson())).toList();
      await prefs.setStringList('bills', billsJson);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting bill: $e');
      }
      rethrow;
    }
  }

  // Search bills
  List<Bill> searchBills(String query) {
    if (query.isEmpty) return _bills;
    
    return _bills.where((bill) {
      return bill.customerName.toLowerCase().contains(query.toLowerCase()) ||
             (bill.id?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             bill.items.any((item) => 
               item.productName.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Get bills by date range
  List<Bill> getBillsByDateRange(DateTime start, DateTime end) {
    return _bills.where((bill) {
      return bill.date.isAfter(start.subtract(const Duration(days: 1))) &&
             bill.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}