import 'product.dart';

class BillingItem {
  final Product product;
  int quantity;
  double price; // Allow price editing

  BillingItem({
    required this.product,
    this.quantity = 1,
    double? price,
  }) : price = price ?? product.price;

  double get totalPrice => price * quantity;

  String get id => product.id;
  String get name => product.name;
  String get productName => product.name;
  String get description => product.description;
  String get category => product.category;
  String get image => product.image;
  bool get isAvailable => product.isAvailable;
  int get stock => product.stock;
  double get total => totalPrice;

  BillingItem copyWith({
    Product? product,
    int? quantity,
    double? price,
  }) {
    return BillingItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }

  factory BillingItem.fromJson(Map<String, dynamic> json) {
    return BillingItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toDouble(),
    );
  }
}
