class Customer {
  final String id;
  final String shopName;
  final String phone;
  final String area;
  final DateTime dateAdded;

  Customer({
    required this.id,
    required this.shopName,
    required this.phone,
    required this.area,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      shopName: json['shopName'],
      phone: json['phone'],
      area: json['area'],
      dateAdded: json['dateAdded'] != null 
          ? DateTime.parse(json['dateAdded']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'phone': phone,
      'area': area,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  Customer copyWith({
    String? shopName,
    String? phone,
    String? area,
  }) {
    return Customer(
      id: id,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      area: area ?? this.area,
      dateAdded: dateAdded,
    );
  }
}
