class Customer {
  final String id;
  final String shopName;
  final String phone;
  final String area;
  final double limit;
  final DateTime dateAdded;

  Customer({
    required this.id,
    required this.shopName,
    required this.phone,
    required this.area,
    required this.limit,
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
      limit: (json['limit'] ?? 0.0).toDouble(),
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
      'limit': limit,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  Customer copyWith({
    String? shopName,
    String? phone,
    String? area,
    double? limit,
  }) {
    return Customer(
      id: id,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      area: area ?? this.area,
      limit: limit ?? this.limit,
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
      limit: (data['limit'] ?? 0.0).toDouble(),
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
      'limit': limit,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
  }
}
