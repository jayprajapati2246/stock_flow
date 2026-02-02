
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/model/PurchaseModel/purchase_model.dart';

class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  String _getPurchasePath() {
    final user = _authController.currentUser.value;
    if (user == null) throw Exception('User not logged in');
    return 'users/${user.uid}/purchases';
  }

  Stream<List<PurchaseModel>> getPurchases() {
    return _firestore.collection(_getPurchasePath()).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PurchaseModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addPurchase(PurchaseModel purchase) {
    return _firestore.collection(_getPurchasePath()).add(purchase.toMap());
  }
}
