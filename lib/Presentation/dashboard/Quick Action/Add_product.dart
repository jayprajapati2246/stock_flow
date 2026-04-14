import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/supplier_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SupplierModel/supplier_model.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Obx(() => PopScope(
        canPop: !controller.isLoading.value,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Text(
              "New Product",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUploadSection(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Identity"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    label: "Product Name",
                    controller: controller.productNameController,
                    icon: Icons.inventory_2_rounded,
                    hint: "e.g. MacBook Pro M3",
                  ),
                  const SizedBox(height: 24),
                  _buildDropdownSection(
                    context,
                    label: "Supplier",
                    child: _buildSupplierDropdown(context),
                  ),
                  const SizedBox(height: 24),
                  _buildDropdownSection(
                    context,
                    label: "Category",
                    child: _buildCategoryDropdown(context),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Pricing & Inventory"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: "Purchase Price",
                          controller: controller.purchasePriceController,
                          icon: Icons.shopping_cart_rounded,
                          hint: "0.00",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          context,
                          label: "Selling Price",
                          controller: controller.priceController,
                          icon: Icons.sell_rounded,
                          hint: "0.00",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    context,
                    label: "Stock Quantity",
                    controller: controller.quantityController,
                    icon: Icons.numbers_rounded,
                    hint: "Initial stock level",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 48),
                  _buildSaveButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: theme.brightness == Brightness.dark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSection(BuildContext context, {required String label, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        child,
      ],
    );
  }

  Widget _buildSupplierDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedSupplierId.value,
                  hint: Text("Select Supplier", style: theme.inputDecorationTheme.hintStyle),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.hintColor),
                  dropdownColor: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  items: supplierController.suppliers.map((Supplier supplier) {
                    return DropdownMenuItem<String>(
                      value: supplier.id,
                      child: Text(supplier.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.selectedSupplierId.value = value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildAddCircleButton(onTap: () => _showAddSupplierDialog(context)),
        ],
      );
    });
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedCategory.value,
                  hint: Text("Select Category", style: theme.inputDecorationTheme.hintStyle),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.hintColor),
                  dropdownColor: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  items: controller.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.selectedCategory.value = value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildAddCircleButton(onTap: () => _showAddCategoryDialog(context)),
        ],
      );
    });
  }

  Widget _buildAddCircleButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          color: PremiumTheme.primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PremiumTheme.primaryColor.withOpacity(0.2)),
        ),
        child: const Icon(Icons.add_rounded, color: PremiumTheme.primaryColor, size: 32),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Obx(() {
      return GestureDetector(
        onTap: controller.isLoading.value ? null : () => controller.pickImage(context),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor, width: 2, style: BorderStyle.solid),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: controller.selectedImage.value != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(controller.selectedImage.value!, fit: BoxFit.cover),
                      Container(color: Colors.black12),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: PremiumTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_a_photo_rounded, size: 40, color: PremiumTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Add Product Photo",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to browse from gallery",
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: controller.isLoading.value ? null : () => controller.saveProduct(context),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: controller.isLoading.value
          ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 24),
                SizedBox(width: 12),
                Text("CREATE PRODUCT", style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w900)),
              ],
            ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Supplier", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                _buildTextField(context, label: "Name", controller: nameController, icon: Icons.person_rounded, hint: "Enter name"),
                const SizedBox(height: 20),
                _buildTextField(context, label: "Contact Info", controller: contactController, icon: Icons.phone_rounded, hint: "Phone or email"),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && contactController.text.isNotEmpty) {
                      final id = await supplierController.addSupplier(nameController.text.trim(), contactController.text.trim());
                      if (id != null) {
                        supplierController.onInit();
                        controller.selectedSupplierId.value = id;
                      }
                      Get.back();
                    }
                  },
                  child: const Text("SAVE SUPPLIER"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Center(child: Text("Cancel", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Category", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                _buildTextField(context, label: "Category Name", controller: categoryController, icon: Icons.category_rounded, hint: "e.g. Hardware"),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (categoryController.text.isNotEmpty) {
                      controller.addCategory(categoryController.text.trim());
                      Get.back();
                    }
                  },
                  child: const Text("SAVE CATEGORY"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Center(child: Text("Cancel", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
