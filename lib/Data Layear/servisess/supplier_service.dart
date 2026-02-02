import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import '../model/SupplierModel/supplier_model.dart';

class SupplierService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final AuthController _authController = Get.find<AuthController>();

  Stream<List<Supplier>> getSuppliers() {
    final user = _authController.currentUser.value;
    if (user == null) return Stream.value([]);

    DatabaseReference ref = _database.ref('users/${user.uid}/suppliers');

    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return <Supplier>[];
      }
      final suppliers = <Supplier>[];
      data.forEach((key, value) {
        suppliers.add(Supplier.fromMap(Map<String, dynamic>.from(value as Map), key as String));
      });
      return suppliers;
    });
  }

  Future<String?> addSupplier(Supplier supplier) async {
    final user = _authController.currentUser.value;
    if (user == null) return null;

    DatabaseReference ref = _database.ref('users/${user.uid}/suppliers').push();
    await ref.set(supplier.toMap());
    return ref.key;
  }

  Future<void> removeSupplier(String supplierId) {
    final user = _authController.currentUser.value;
    if (user == null) return Future.value();

    DatabaseReference ref = _database.ref('users/${user.uid}/suppliers/$supplierId');
    return ref.remove();
  }

  Future<void> updateSupplierTotalPurchase(String supplierId, double total) {
    final user = _authController.currentUser.value;
    if (user == null) return Future.value();

    DatabaseReference ref = _database.ref('users/${user.uid}/suppliers/$supplierId');
    return ref.update({'totalPurchase': total});
  }
}
