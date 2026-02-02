import 'dart:async';
import 'package:get/get.dart';
import '../model/SupplierModel/supplier_model.dart';
import '../servisess/supplier_service.dart';

class SupplierController extends GetxController {
  final SupplierService _supplierService = SupplierService();
  final suppliers = <Supplier>[].obs;
  final isLoading = true.obs;
  final error = RxnString();
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _supplierService.getSuppliers().listen(
      (supplierData) {
        suppliers.value = supplierData;
        isLoading.value = false;
        error.value = null;
      },
      onError: (err) {
        error.value = "Error fetching suppliers: ${err.toString()}";
        isLoading.value = false;
        Get.snackbar(
          "Data Fetch Error",
          "Could not load supplier data. Please check your connection or database.",
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onDone: () {
        isLoading.value = false;
      },
    );
  }

  Future<String?> addSupplier(String name, String contact) async {
    try {
      final newSupplier = Supplier(name: name, contact: contact, totalPurchase: 0.0);
      final newId = await _supplierService.addSupplier(newSupplier);
      return newId;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add supplier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<void> removeSupplier(String supplierId) async {
    try {
      await _supplierService.removeSupplier(supplierId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove supplier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
