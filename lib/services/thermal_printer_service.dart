import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../models/bill.dart';
import '../models/billing_item.dart';
import '../models/product.dart';
import 'bluetooth_service.dart';

class ThermalPrinterService {
  static const String _shopName = "PEGAS POS";
  static const String _shopAddress = "Your Shop Address\nPhone: +94 XX XXX XXXX";

  /// Print a bill to the connected thermal printer
  static Future<bool> printBill(Bill bill) async {
    if (!BluetoothService.isConnected) {
      debugPrint('No printer connected');
      return false;
    }

    try {
      // Mock print implementation - generate simple text version of bill
      String billText = _generateBillText(bill);
      List<int> data = utf8.encode(billText);
      
      debugPrint('Mock: Printing bill to thermal printer');
      debugPrint('Bill content:\n$billText');
      
      // Send data to mock Bluetooth service
      bool success = await BluetoothService.sendData(data);
      
      if (success) {
        debugPrint('Mock: Bill printed successfully');
        return true;
      } else {
        debugPrint('Mock: Failed to send bill data');
        return false;
      }
    } catch (e) {
      debugPrint('Mock: Error printing bill: $e');
      return false;
    }
  }

  /// Generate bill text for printing
  static String _generateBillText(Bill bill) {
    StringBuffer buffer = StringBuffer();
    
    // Header
    buffer.writeln('================================');
    buffer.writeln('         $_shopName         ');
    buffer.writeln('================================');
    buffer.writeln(_shopAddress);
    buffer.writeln('================================');
    buffer.writeln();
    
    // Bill details
    buffer.writeln('INVOICE');
    buffer.writeln('Bill ID: ${bill.id}');
    buffer.writeln('Date: ${_formatDateTime(bill.timestamp)}');
    buffer.writeln('Customer: ${bill.customerName}');
    if (bill.customerPhone.isNotEmpty) {
      buffer.writeln('Phone: ${bill.customerPhone}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln();
    
    // Items header
    buffer.writeln('Item                Qty   Price');
    buffer.writeln('--------------------------------');
    
    // Items
    for (BillingItem item in bill.items) {
      String itemName = item.name.length > 15 
          ? '${item.name.substring(0, 15)}...' 
          : item.name.padRight(18);
      String qty = item.quantity.toString().padLeft(3);
      String price = item.price.toStringAsFixed(2).padLeft(8);
      
      buffer.writeln('$itemName $qty $price');
      
      // Add total for this item if quantity > 1
      if (item.quantity > 1) {
        String total = (item.price * item.quantity).toStringAsFixed(2);
        buffer.writeln('  Total: Rs. $total');
      }
    }
    
    buffer.writeln('--------------------------------');
    
    // Totals
    buffer.writeln('Subtotal:           Rs. ${bill.subtotal.toStringAsFixed(2)}');
    if (bill.discount > 0) {
      buffer.writeln('Discount:           Rs. ${bill.discount.toStringAsFixed(2)}');
    }
    buffer.writeln('TOTAL:              Rs. ${bill.totalAmount.toStringAsFixed(2)}');
    
    buffer.writeln('================================');
    buffer.writeln('     Thank you for your visit!     ');
    buffer.writeln('       Please come again!       ');
    buffer.writeln('================================');
    buffer.writeln();
    buffer.writeln();
    buffer.writeln();
    
    return buffer.toString();
  }

  /// Print a test page to verify printer connection
  static Future<bool> printTestPage() async {
    if (!BluetoothService.isConnected) {
      debugPrint('No printer connected');
      return false;
    }

    try {
      String testText = _generateTestPageText();
      List<int> data = utf8.encode(testText);
      
      debugPrint('Mock: Printing test page');
      debugPrint('Test page content:\n$testText');
      
      bool success = await BluetoothService.sendData(data);
      
      if (success) {
        debugPrint('Mock: Test page printed successfully');
        return true;
      } else {
        debugPrint('Mock: Failed to send test page data');
        return false;
      }
    } catch (e) {
      debugPrint('Mock: Error printing test page: $e');
      return false;
    }
  }

  /// Generate test page text
  static String _generateTestPageText() {
    StringBuffer buffer = StringBuffer();
    
    buffer.writeln('================================');
    buffer.writeln('         TEST PAGE         ');
    buffer.writeln('================================');
    buffer.writeln('         $_shopName         ');
    buffer.writeln('--------------------------------');
    buffer.writeln();
    buffer.writeln('Date: ${_formatDateTime(DateTime.now())}');
    buffer.writeln();
    buffer.writeln('This is a test print to verify');
    buffer.writeln('the printer connection is working');
    buffer.writeln('properly.');
    buffer.writeln();
    buffer.writeln('If you can see this message,');
    buffer.writeln('your printer is connected');
    buffer.writeln('successfully!');
    buffer.writeln();
    buffer.writeln('================================');
    buffer.writeln('      Test Completed      ');
    buffer.writeln('================================');
    buffer.writeln();
    buffer.writeln();
    
    return buffer.toString();
  }

  /// Format date and time for printing
  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  /// Create a sample bill for testing (used in test methods)
  static Bill createSampleBill() {
    return Bill(
      id: 'TEST001',
      billNumber: 'TEST001',
      customerName: 'Test Customer',
      customerPhone: '+94712345678',
      items: [
        BillingItem(
          product: Product(
            id: '1',
            name: 'Test Product 1',
            category: 'Test',
            description: 'Test description 1',
            price: 150.00,
            image: '',
            stock: 10,
          ),
          quantity: 2,
          price: 150.00,
        ),
        BillingItem(
          product: Product(
            id: '2',
            name: 'Test Product 2',
            category: 'Test',
            description: 'Test description 2',
            price: 75.50,
            image: '',
            stock: 5,
          ),
          quantity: 1,
          price: 75.50,
        ),
      ],
      subtotal: 375.50,
      discount: 25.50,
      totalAmount: 350.00,
      timestamp: DateTime.now(),
    );
  }
}