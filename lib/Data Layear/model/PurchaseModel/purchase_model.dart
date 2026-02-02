import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String? id;
  final String supplierId;
  final double total;
  final double paidAmount;
  final DateTime timestamp;

  PurchaseModel({
    this.id,
    required this.supplierId,
    required this.total,
    this.paidAmount = 0.0,
    required this.timestamp,
  });

  factory PurchaseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PurchaseModel(
      id: doc.id,
      supplierId: data['supplierId'] ?? '',
      total: (data['total'] as num).toDouble(),
      paidAmount: (data['paidAmount'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'total': total,
      'paidAmount': paidAmount,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
