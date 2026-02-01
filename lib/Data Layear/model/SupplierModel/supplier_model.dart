class SupplierModel {
  final String id;
  final String name;
  final String contact;
  final double totalPurchase;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.totalPurchase,
  });

  factory SupplierModel.fromMap(String id, Map<String, dynamic> data) {
    return SupplierModel(
      id: id,
      name: data['name'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      totalPurchase: (data['totalPurchase'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
