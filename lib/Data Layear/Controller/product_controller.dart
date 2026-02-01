import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import 'package:stock_flow/Comon%20part%20for%20all/Scack%20bar/snackbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/purchase_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Data%20Layear/servisess/database_product.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  // ---------------- Controllers ----------------
  final productNameController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final quantityController = TextEditingController();
  final searchController = TextEditingController();

  var selectedSupplierId = RxnString();

  var categories = <String>[
    'Other',
    'Electronics',
    'Clothing',
    'Furniture',
    'Home Appliances',
    'Sports Equipment',
    'Books',
    'Beauty & Personal Care',
    'Groceries',
    'Toys & Games',
    'Automotive',
    'Jewelry & Accessories',
  ].obs;

  var selectedCategory = RxnString();
  var selectedImage = Rxn<File>();

  final ImagePicker _picker = ImagePicker();
  final isLoading = false.obs;
  var allProducts = <ProductModel>[].obs;

  // ---------------- Cloudinary ----------------
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dtu8dmez4',
    'Stock_Flow',
    cache: false,
  );

  // ---------------- Init ----------------
  @override
  void onInit() {
    super.onInit();
    allProducts.bindStream(_productService.getProducts());
  }

  // ---------------- Stock Helpers ----------------
  int get lowStockCount =>
      allProducts.where((product) => product.quantity <= 10).length;

  List<ProductModel> get lowStockProducts =>
      allProducts.where((product) => product.quantity <= 10).toList();

  void addCategory(String category) {
    if (category.isNotEmpty && !categories.contains(category)) {
      categories.add(category);
      selectedCategory.value = category;
    }
  }

  // ---------------- Image Picker ----------------
  Future<void> pickImage(BuildContext context) async {
    try {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: "Error picking image: $e",
        type: SnackBarType.error,
      );
    }
  }

  // ---------------- Cloudinary Upload ----------------
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      return null;
    }
  }

  // ---------------- Save Product ----------------
  Future<void> saveProduct(BuildContext context) async {
    final name = productNameController.text.trim();
    final sku = skuController.text.trim();
    final priceStr = priceController.text.trim();
    final purchasePriceStr = purchasePriceController.text.trim();
    final qtyStr = quantityController.text.trim();
    final category = selectedCategory.value;
    final supplierId = selectedSupplierId.value;

    if (name.isEmpty ||
        priceStr.isEmpty ||
        purchasePriceStr.isEmpty ||
        qtyStr.isEmpty ||
        category == null ||
        supplierId == null) {
      CustomSnackBar.show(
        context: context,
        message: "Please fill all required fields",
        type: SnackBarType.warning,
      );
      return;
    }

    isLoading.value = true;

    try {
      String imageUrl = "";

      // 🔥 Upload image first
      if (selectedImage.value != null) {
        final uploadedUrl =
        await _uploadImageToCloudinary(selectedImage.value!);

        if (uploadedUrl == null) {
          throw "Image upload failed";
        }
        imageUrl = uploadedUrl;
      }

      // 🔥 Save product with Cloudinary URL
      final product = ProductModel(
        name: name,
        sku: sku,
        price: double.tryParse(priceStr) ?? 0.0,
        purchasePrice: double.tryParse(purchasePriceStr) ?? 0.0,
        quantity: int.tryParse(qtyStr) ?? 0,
        category: category,
        supplierId: supplierId,
        image: imageUrl, // ✅ Cloudinary URL
      );

      await _productService.addProduct(product);

      // 🔥 Purchase record
      final purchaseTotal =
          (double.tryParse(purchasePriceStr) ?? 0.0) *
              (int.tryParse(qtyStr) ?? 0);

      final PurchaseController purchaseController =
      Get.put(PurchaseController());

      await purchaseController.addPurchase(
        supplierId: supplierId,
        total: purchaseTotal,
      );

      CustomSnackBar.show(
        context: context,
        message: "Product saved successfully!",
        type: SnackBarType.success,
      );

      _clearFields();
      Get.back();
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: "Error saving product: $e",
        type: SnackBarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Clear ----------------
  void _clearFields() {
    productNameController.clear();
    skuController.clear();
    priceController.clear();
    purchasePriceController.clear();
    quantityController.clear();
    selectedSupplierId.value = null;
    selectedCategory.value = null;
    selectedImage.value = null;
  }

  // ---------------- Delete ----------------
  Future<void> removeProduct(BuildContext context, String id) async {
    Get.defaultDialog(
      title: "Delete Product",
      middleText: "Are you sure you want to delete this product?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        try {
          await _productService.deleteProduct(id);
          CustomSnackBar.show(
            context: context,
            message: "Product removed!",
            type: SnackBarType.info,
          );
        } catch (e) {
          CustomSnackBar.show(
            context: context,
            message: "Error removing product: $e",
            type: SnackBarType.error,
          );
        }
      },
    );
  }

  Future<void> removeAllProducts(BuildContext context) async {
    try {
      for (var product in allProducts) {
        if (product.id != null) {
          await _productService.deleteProduct(product.id!);
        }
      }
      CustomSnackBar.show(
        context: context,
        message: "All products removed!",
        type: SnackBarType.warning,
      );
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: "Error removing all products: $e",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> updateProductInDatabase(ProductModel product) async {
    try {
      await _productService.updateProduct(product);
    } catch (e) {
      debugPrint("Error updating product: $e");
    }
  }
}
