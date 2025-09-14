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

  // Getter for compatibility
  String get name => shopName;

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

  // Firebase methods
  factory Customer.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Customer(
      id: documentId,
      shopName: data['shopName'] ?? '',
      phone: data['phone'] ?? '',
      area: data['area'] ?? '',
      dateAdded: data['dateAdded'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['dateAdded'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shopName': shopName,
      'phone': phone,
      'area': area,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
  }
}
