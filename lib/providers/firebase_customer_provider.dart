import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/firebase_service.dart';

class FirebaseCustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Customer> get customers => List.unmodifiable(_customers);
  bool get isLoading => _isLoading;
  String? get error => _error;

  FirebaseCustomerProvider() {
    loadCustomers();
  }

  // Load customers from Firebase
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await FirebaseService.getCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new customer
  Future<void> addCustomer(Customer customer) async {
    try {
      await FirebaseService.addCustomer(customer);
      await loadCustomers(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add customer: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update existing customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      await FirebaseService.updateCustomer(customer.id, customer);
      await loadCustomers(); // Refresh the list
    } catch (e) {
      _error = 'Failed to update customer: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await FirebaseService.deleteCustomer(customerId);
      await loadCustomers(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete customer: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Search customers
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;
    
    return _customers.where((customer) =>
      customer.shopName.toLowerCase().contains(query.toLowerCase()) ||
      customer.phone.contains(query) ||
      customer.area.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get customers by area
  List<Customer> getCustomersByArea(String area) {
    return _customers.where((customer) =>
      customer.area.toLowerCase() == area.toLowerCase()).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Listen to real-time customer updates
  void listenToCustomers() {
    FirebaseService.getCustomersStream().listen((customers) {
      _customers = customers;
      notifyListeners();
    });
  }
}