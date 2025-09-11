import 'customer.dart';
import 'billing_item.dart';

class Bill {
  final String id;
  final DateTime date;
  final Customer? customer;
  final List<BillingItem> items;
  final double subtotal;
  final double discountAmount;
  final double discountPercentage;
  final double total;
  final String paymentMethod;
  final String status; // 'completed', 'pending', 'cancelled'

  Bill({
    required this.id,
    required this.date,
    this.customer,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.discountPercentage = 0.0,
    required this.total,
    this.paymentMethod = 'cash',
    this.status = 'completed',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customer': customer?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      date: DateTime.parse(json['date']),
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      items: (json['items'] as List).map((item) => BillingItem.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
      discountPercentage: json['discountPercentage']?.toDouble() ?? 0.0,
      total: json['total'].toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      status: json['status'] ?? 'completed',
    );
  }
}
