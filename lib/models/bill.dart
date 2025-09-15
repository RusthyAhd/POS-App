import 'customer.dart';
import 'billing_item.dart';

class Bill {
  String? id;
  final String billNumber;
  final String customerName;
  final String customerPhone;
  final List<BillingItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String paymentMethod;
  final DateTime timestamp;
  final String status; // 'completed', 'pending', 'cancelled'

  // Legacy fields for compatibility
  DateTime get date => timestamp;
  Customer? get customer => customerPhone.isNotEmpty 
      ? Customer(
          id: customerPhone,
          shopName: customerName,
          phone: customerPhone,
          area: '',
          limit: 0.0,
        ) 
      : null;
  double get total => totalAmount;
  double get discountAmount => discount;
  double get discountPercentage => subtotal > 0 ? (discount / subtotal) * 100 : 0;

  Bill({
    this.id,
    required this.billNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    this.paymentMethod = 'Cash',
    required this.timestamp,
    this.status = 'completed',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billNumber': billNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      billNumber: json['billNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      items: (json['items'] as List? ?? []).map((item) => BillingItem.fromJson(item)).toList(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      status: json['status'] ?? 'completed',
    );
  }
}
