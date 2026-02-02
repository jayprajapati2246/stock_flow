import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

class ProductService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final AuthController _authController = Get.find<AuthController>();

  // New Structure: users / {userId} / products
  String? get _productRootPath {
    final user = _authController.currentUser.value;
    if (user == null) return null;
    return 'users/${user.uid}/products';
  }

  Stream<List<ProductModel>> getProducts() {
    final user = _authController.currentUser.value;
    if (user == null) {
      return Stream.value(<ProductModel>[]);
    }

    final path = 'users/${user.uid}/products';
    return _db.child(path).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) {
        return <ProductModel>[];
      }

      final data = snapshot.value;
      if (data is Map) {
        return data.entries.map((entry) {
          final value = entry.value;
          if (value is Map) {
            return ProductModel.fromMap(Map<String, dynamic>.from(value));
          }
          return null;
        }).whereType<ProductModel>().toList();
      }
      return <ProductModel>[];
    });
  }

  Future<void> addProduct(ProductModel product) async {
    final path = _productRootPath;
    if (path == null) {
      throw Exception("User not authenticated. Cannot add product.");
    }

    final productRef = _db.child(path).push();
    final id = productRef.key;
    final productData = product.toMap();
    productData['id'] = id;
    await productRef.set(productData);
  }

  Future<void> updateProduct(ProductModel product) async {
    final path = _productRootPath;
    if (path == null) throw Exception("User not authenticated");
    if (product.id == null) throw Exception("Product ID is missing");

    final productRef = _db.child(path).child(product.id!);
    await productRef.update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    final path = _productRootPath;
    if (path == null) throw Exception("User not authenticated");

    final productRef = _db.child(path).child(productId);
    await productRef.remove();
  }
}
