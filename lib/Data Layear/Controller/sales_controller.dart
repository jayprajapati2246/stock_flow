import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_flow/Data Layear/Controller/product_controller.dart' show ProductController;
import 'package:stock_flow/Data Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Data Layear/model/SaleModel/sale_model.dart';
import 'package:stock_flow/Data Layear/servisess/sales_service.dart';

enum ProductFilter { all, lowStock }
enum ProductSort { aToZ, zToA, priceHighToLow, priceLowToHigh }

class SalesController extends GetxController {
  final ProductController _productController = Get.find<ProductController>();
  final SalesService _salesService = SalesService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var sales = <SaleModel>[].obs;
  var selectedDate = DateTime.now().obs;

  var allProducts = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;

  // Filter and Sort State
  final selectedFilter = ProductFilter.all.obs;
  final Rx<ProductSort?> selectedSort = Rx<ProductSort?>(null);

  final TextEditingController searchController = TextEditingController();
  final TextEditingController discountController = TextEditingController(text: "0");

  var cartItems = <Map<String, dynamic>>[].obs;
  var discountPercentage = 0.0.obs;

  final paymentMethods = ['Cash', 'Card', 'Online'];
  var selectedPaymentMethod = 'Cash'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
    allProducts.assignAll(_productController.allProducts);
    filterProducts(searchController.text);

    _productController.allProducts.listen((products) {
      allProducts.assignAll(products);
      filterProducts(searchController.text);
    });

    searchController.addListener(() {
      filterProducts(searchController.text);
    });
  }

  Future<void> fetchSales() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _salesService.getUserSales(uid).listen((salesData) {
        sales.assignAll(salesData);
      });
    }
  }

  void setFilter(ProductFilter filter) {
    selectedFilter.value = filter;
    filterProducts(searchController.text);
  }

  void setSort(ProductSort? sort) {
    selectedSort.value = sort;
    filterProducts(searchController.text);
  }

  void filterProducts(String query) {
    var tempProducts = allProducts.where((product) {
      final nameMatches = product.name.toLowerCase().contains(query.toLowerCase());
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

    filteredProducts.assignAll(tempProducts);
  }

  void addToCart(ProductModel product, [int quantity = 1]) {
    final index = cartItems.indexWhere((e) => e['id'] == product.id);
    if (index != -1) {
      cartItems[index]['quantity'] += quantity;
      cartItems.refresh();
    } else {
      cartItems.add({
        "id": product.id,
        "name": product.name,
        "price": product.price,
        "quantity": quantity,
      });
    }
  }

  double get subtotal =>
      cartItems.fold(0.0, (s, i) => s + (i['price'] * i['quantity']));

  double get discountAmount => (subtotal * discountPercentage.value) / 100;

  double get totalAmount => subtotal - discountAmount;

  void updateDiscount(String value) {
    discountPercentage.value = double.tryParse(value) ?? 0.0;
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> completeSale() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      Get.snackbar("Error", "You must be logged in to complete a sale.");
      return;
    }

    if (cartItems.isEmpty) {
      Get.snackbar("Error", "Your cart is empty.");
      return;
    }

    final sale = SaleModel(
      date: selectedDate.value,
      items: cartItems,
      subtotal: subtotal,
      discount: discountAmount,
      totalAmount: totalAmount,
      paymentMethod: selectedPaymentMethod.value,
    );

    try {
      await _salesService.addSale(
        uid: uid,
        sale: sale,
      );

      // Update product stock
      for (var item in cartItems) {
        final product = _productController.allProducts
            .firstWhereOrNull((p) => p!.id == item['id']);
        if (product != null) {
          final updatedProduct = product.copyWith(
              quantity: product.quantity - (item['quantity'] as int));
          await _productController.updateProductInDatabase(updatedProduct);
        } else {
          print("Error: Product with ID ${item['id']} not found in product list.");
        }
      }

      cartItems.clear();
      discountController.text = "0";
      discountPercentage.value = 0.0;
      searchController.clear();

      Get.snackbar(
        "Success",
        "Sale completed successfully!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
        boxShadows: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to complete sale: ${e.toString()}");
    }
  }
}
