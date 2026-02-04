import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Scack%20bar/snackbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

enum ProductFilter { all, lowStock }
enum ProductSort { aToZ, zToA, priceHighToLow, priceLowToHigh }

class DashboardManageController extends GetxController {
  final ProductController productController = Get.find<ProductController>();

  final manageQuantitySearchController = TextEditingController();
  final searchQuery = ''.obs;

  // Filter and Sort State
  final selectedFilter = ProductFilter.all.obs;
  final Rx<ProductSort?> selectedSort = Rx<ProductSort?>(null);

  // productId → adjustment (starts from 0)
  final RxMap<String, int> tempAdjustments = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    manageQuantitySearchController.addListener(() {
      searchQuery.value = manageQuantitySearchController.text.toLowerCase();
    });
  }

  void setFilter(ProductFilter filter) {
    selectedFilter.value = filter;
  }

  void setSort(ProductSort? sort) {
    selectedSort.value = sort;
  }

  List<ProductModel> get filteredProducts {
    var tempProducts = productController.allProducts.where((product) {
      final nameMatches = product.name.toLowerCase().contains(searchQuery.value);
      if (selectedFilter.value == ProductFilter.lowStock) {
        return nameMatches && product.quantity <= 5;
      }
      return nameMatches;
    }).toList();

    if (selectedSort.value != null) {
      tempProducts.sort((a, b) {
        switch (selectedSort.value!) {
          case ProductSort.aToZ:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case ProductSort.zToA:
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          case ProductSort.priceHighToLow:
            return b.price.compareTo(a.price);
          case ProductSort.priceLowToHigh:
            return a.price.compareTo(b.price);
        }
      });
    }

    return tempProducts;
  }

  // + / - change (ALWAYS starts from 0)
  void updateAdjustment(String productId, int delta) {
    final product = productController.allProducts.firstWhere((p) => p.id == productId);

    // Prevent negative final stock
    if (product.quantity + delta < 0) return;

    tempAdjustments[productId] = delta;
    tempAdjustments.refresh(); //  IMPORTANT
  }

  int getAdjustment(String productId) {
    return tempAdjustments[productId] ?? 0;
  }

  // SAVE TO DATABASE
  Future<void> saveChanges(BuildContext context) async {
    if (tempAdjustments.isEmpty) return;

    productController.isLoading.value = true;

    try {
      for (final entry in tempAdjustments.entries) {
        if (entry.value == 0) continue;

        final product =
        productController.allProducts.firstWhere((p) => p.id == entry.key);

        final newQuantity = product.quantity + entry.value;

        final updatedProduct = ProductModel(
          id: product.id,
          name: product.name,
          category: product.category,
          price: product.price,
          quantity: newQuantity < 0 ? 0 : newQuantity,
          supplierId: product.supplierId, // Corrected from supplier to supplierId
          image: product.image,
          purchasePrice: product.purchasePrice,
          sku: product.sku,
        );

        await productController.updateProductInDatabase(updatedProduct);
      }

      tempAdjustments.clear();

      CustomSnackBar.show(
        context: context,
        message: "Inventory updated successfully",
        duration: const Duration(seconds: 1),
        type: SnackBarType.success,
      );
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: "Error: $e",
        type: SnackBarType.error,
      );
    } finally {
      productController.isLoading.value = false;
    }
  }

  @override
  void onClose() {
    manageQuantitySearchController.dispose();
    super.onClose();
  }
}