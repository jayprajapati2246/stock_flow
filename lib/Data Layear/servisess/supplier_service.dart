import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SupplierModel/supplier_model.dart';

class SupplierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  String _getSuppliersPath() {
    final user = _authController.currentUser.value;
    if (user == null) throw Exception('User not logged in');
    return 'users/${user.uid}/suppliers';
  }

  Stream<List<Supplier>> getSuppliers() {
    return _firestore
        .collection(_getSuppliersPath())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Supplier.fromFirestore(doc)).toList());
  }

  Future<void> addSupplier(Supplier supplier) {
    return _firestore.collection(_getSuppliersPath()).add(supplier.toFirestore