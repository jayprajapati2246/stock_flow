import 'package:firebase_database/firebase_database.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';

class SalesService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Add Sale under specific user
  Future<void> addSale({
    required String uid,
    required SaleModel sale,
  }) async {
    final userSalesRef = _dbRef
        .child('users')
        .child(uid)
        .child('sales')
        .push();

    sale.id = userSalesRef.key;

    await userSalesRef.set(sale.toJson());
  }

  /// Get sales of specific user
  Stream<List<SaleModel>> getUserSales(String uid) {
    return _dbRef
        .child('users')
        .child(uid)
        .child('sales')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final salesList = data.entries.map((entry) {
        return SaleModel.fromJson(
          Map<String, dynamic>.from(entry.value),
        );
      }).toList();

      // newest first
      salesList.sort((a, b) => b.date.compareTo(a.date));
      return salesList;
    });
  }

  /// Delete a sale
  Future<void> deleteSale({
    required String uid,
    required String saleId,
  }) async {
    await _dbRef
        .child('users')
        .child(uid)
        .child('sales')
        .child(saleId)
        .remove();
  }
}
