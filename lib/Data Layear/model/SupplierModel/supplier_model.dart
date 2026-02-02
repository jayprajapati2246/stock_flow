class Supplier {
  final String? id;
  final String name;
  final String contact;
  final double totalPurchase;

  Supplier({
    this.id,
    required this.name,
    required this.contact,
    required this.totalPurchase,
  });

  factory Supplier.fromMap(Map<String, dynamic> data, String id) {
    return Supplier(
      id: id,
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      totalPurchase: (data['totalPurchase'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'totalPurchase': totalPurchase,
    };
  }
}
