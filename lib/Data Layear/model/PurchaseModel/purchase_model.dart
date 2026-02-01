class PurchaseModel {
  final String id;
  final String supplierId;
  final double total;
  final double paidAmount;
  final int timestamp;

  PurchaseModel({
    required this.id,
    required this.supplierId,
    required this.total,
    this.paidAmount = 0.0,
    required this.timestamp,
  });

  factory PurchaseModel.fromMap(String id, Map<String, dynamic> data) {
    return PurchaseModel(
      id: id,
      supplierId: data['supplierId'] as String? ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (data['paidAmount'] as num?)?.toDouble() ?? 0.0,
      timestamp: data['timestamp'] as int? ?? 0,
    );
  }
}
