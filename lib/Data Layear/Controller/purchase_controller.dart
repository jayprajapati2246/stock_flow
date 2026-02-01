import 'package:get/get.dart';
import 'package:stock_flow/Data Layear/model/PurchaseModel/purchase_model.dart';
import 'package:stock_flow/Data Layear/servisess/purchase_service.dart';
import 'package:stock_flow/Data Layear/servisess/supplier_service.dart'; // Import SupplierService

class PurchaseController extends GetxController {
  final PurchaseService _purchaseService = PurchaseService();
  final SupplierService _supplierService =
      SupplierService(); // Instantiate SupplierService
  final purchases = <PurchaseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    purchases.bindStream(_purchaseService.getPurchases());
  }

  Future<void> addPurchase(
      {required String supplierId, required double total}) async {
    try {
      // Add the purchase
      await _purchaseService.addPurchase({
        'supplierId': supplierId,
        'total': total,
        'paidAmount': 0.0, // Default to 0, can be updated later
        'timestamp':
            DateTime.now().millisecondsSinceEpoch, // RTDB-compatible timestamp
      });

      // Update the supplier's total purchase amount
      await _supplierService.updateSupplierTotalPurchase(supplierId, total);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add purchase: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}