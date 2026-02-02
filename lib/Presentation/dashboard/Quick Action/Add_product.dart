import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Data Layear/Controller/product_controller.dart';
import '../../../Data Layear/Controller/supplier_controller.dart';
import '../../../Data Layear/model/SupplierModel/supplier_model.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ProductController controller = Get.find<ProductController>();
  final SupplierController supplierController = Get.put(SupplierController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async => !controller.isLoading.value,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1976D2),
            elevation: 0,
            title: const Text(
              "Add Product",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildUploadSection(controller, context),
                  const SizedBox(height: 20),
                  _buildTextField("Product Name", controller.productNameController),
                  const SizedBox(height: 10),
                  _buildSupplierDropdown(supplierController, controller),
                  const SizedBox(height: 10),
                  _buildCategoryDropdown(controller),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Purchase Price",
                    controller.purchasePriceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Selling Price",
                    controller.priceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Stock Quantity",
                    controller.quantityController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildSaveButton(controller, context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TextField ----------------
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  // ---------------- Supplier Dropdown ----------------
  Widget _buildSupplierDropdown(
    SupplierController supController,
    ProductController prodController,
  ) {
    return Obx(() {
      if (supController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: prodController.selectedSupplierId.value,
                  hint: const Text("Select Supplier"),
                  isExpanded: true,
                  items: supController.suppliers.map((Supplier supplier) {
                    return DropdownMenuItem<String>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    prodController.selectedSupplierId.value = value;
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                _showAddSupplierDialog(Get.context!, supController, prodController),
          ),
        ],
      );
    });
  }

  // ---------------- Category Dropdown ----------------
  Widget _buildCategoryDropdown(ProductController controller) {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedCategory.value,
                  hint: const Text("Select Category"),
                  isExpanded: true,
                  items: controller.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedCategory.value = value;
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(Get.context!, controller),
          ),
        ],
      );
    });
  }

  // ---------------- Upload Section ----------------
  Widget _buildUploadSection(
    ProductController controller,
    BuildContext context,
  ) {
    return Obx(() {
      return GestureDetector(
        onTap: controller.isLoading.value
            ? null
            : () => controller.pickImage(context),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: controller.selectedImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    controller.selectedImage.value!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "Tap to upload product image",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  // ---------------- Save Button ----------------
  Widget _buildSaveButton(ProductController controller, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.saveProduct(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Save Product",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ---------------- Dialogs ----------------
  void _showAddSupplierDialog(
    BuildContext context,
    SupplierController supController,
    ProductController prodController,
  ) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();

    Get.defaultDialog(
      title: "Add Supplier",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Supplier Name"),
          ),
          TextField(
            controller: contactController,
            decoration: const InputDecoration(labelText: "Contact Info"),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (nameController.text.isNotEmpty &&
              contactController.text.isNotEmpty) {
            final id = await supController.addSupplier(
              nameController.text.trim(),
              contactController.text.trim(),
            );
            if (id != null) {
              // Refresh the supplier list to include the new one
              supController.onInit();
              // Set the new supplier as selected
              prodController.selectedSupplierId.value = id;
            }
            Get.back();
          }
        },
        child: const Text("Save"),
      ),
      cancel: TextButton(
        onPressed: Get.back,
        child: const Text("Cancel"),
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    ProductController controller,
  ) {
    final categoryController = TextEditingController();

    Get.defaultDialog(
      title: "Add Category",
      content: TextField(
        controller: categoryController,
        decoration: const InputDecoration(labelText: "Category Name"),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (categoryController.text.isNotEmpty) {
            controller.addCategory(categoryController.text.trim());
            Get.back();
          }
        },
        child: const Text("Save"),
      ),
      cancel: TextButton(
        onPressed: Get.back,
        child: const Text("Cancel"),
      ),
    );
  }
}
