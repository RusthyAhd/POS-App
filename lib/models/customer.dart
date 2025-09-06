class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final DateTime dateAdded;
  final double totalPurchases;
  final int totalOrders;
  final String customerType; // 'regular', 'premium', 'vip'
  final String notes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    DateTime? dateAdded,
    this.totalPurchases = 0.0,
    this.totalOrders = 0,
    this.customerType = 'regular',
    this.notes = '',
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      dateAdded: json['dateAdded'] != null 
          ? DateTime.parse(json['dateAdded']) 
          : DateTime.now(),
      totalPurchases: json['totalPurchases']?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] ?? 0,
      customerType: json['customerType'] ?? 'regular',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'dateAdded': dateAdded.toIso8601String(),
      'totalPurchases': totalPurchases,
      'totalOrders': totalOrders,
      'customerType': customerType,
      'notes': notes,
    };
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? totalPurchases,
    int? totalOrders,
    String? customerType,
    String? notes,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      dateAdded: dateAdded,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalOrders: totalOrders ?? this.totalOrders,
      customerType: customerType ?? this.customerType,
      notes: notes ?? this.notes,
    );
  }
}
