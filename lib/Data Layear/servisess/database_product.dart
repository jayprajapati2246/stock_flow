import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

class DatabaseProduct {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  String _getProductsPath() {
    final user = _authController.currentUser.value;
    if (user == null) throw Exception('User not logged in');
    return 'users/${user.uid}/products';
  }

  Stream<List<Product>> getProducts() {
    return _firestore
        .collection(_getProductsPath())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<void> addProduct(Product product) {
    final path = _getProductsPath();
    return _firestore.collection(path).add(product.toFirestore());
  }
}
