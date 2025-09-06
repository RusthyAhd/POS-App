class StockUpdate {
  final String productId;
  final String productName;
  final int oldStock;
  final int newStock;
  final int quantity;
  final String type; // 'add', 'remove', 'adjust'
  final DateTime date;
  final String reason;

  StockUpdate({
    required this.productId,
    required this.productName,
    required this.oldStock,
    required this.newStock,
    required this.quantity,
    required this.type,
    required this.date,
    this.reason = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'oldStock': oldStock,
      'newStock': newStock,
      'quantity': quantity,
      'type': type,
      'date': date.toIso8601String(),
      'reason': reason,
    };
  }

  factory StockUpdate.fromJson(Map<String, dynamic> json) {
    return StockUpdate(
      productId: json['productId'],
      productName: json['productName'],
      oldStock: json['oldStock'],
      newStock: json['newStock'],
      quantity: json['quantity'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      reason: json['reason'] ?? '',
    );
  }
}
