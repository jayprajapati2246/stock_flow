import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Scack%20bar/snackbar.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final ProductController controller = Get.find<ProductController>();
  late ProductModel product;

  final TextEditingController pname = TextEditingController();
  final TextEditingController pdescription = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    product = Get.arguments as ProductModel;
    pname.text = product.name;
    pdescription.text = product.sku; 
    price.text = product.price.toString();
    categoryController.text = product.category;
    quantityController.text = product.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, 
              color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, 
              size: 20
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Edit Product",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Potential delete action if needed, or just leave as is
              },
              icon: const Icon(Icons.delete_outline_rounded, color: PremiumTheme.secondaryColor),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context),
                const SizedBox(height: 40),
                _buildSectionTitle(context, "General Details"),
                const SizedBox(height: 16),
                _buildInputField(context, pname, label: "Product Name", icon: Icons.inventory_2_outlined),
                const SizedBox(height: 16),
                _buildInputField(context, pdescription, label: "SKU / Description", icon: Icons.description_outlined),
                const SizedBox(height: 16),
                _buildInputField(context, categoryController, label: "Category", icon: Icons.category_outlined),
                const SizedBox(height: 32),
                _buildSectionTitle(context, "Stock & Pricing"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInputField(context, quantityController, label: "Quantity", icon: Icons.numbers_rounded, keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField(context, price, label: "Price (₹)", icon: Icons.sell_outlined, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 48),
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: theme.brightness == Brightness.dark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Stack(
        children: [
          Hero(
            tag: 'product_card_${product.id}',
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: theme.dividerColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, size: 48, color: theme.dividerColor),
                      )
                    : Icon(Icons.inventory_2_rounded, size: 64, color: PremiumTheme.primaryColor.withOpacity(0.5)),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: () {
                // Implementation for updating image
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PremiumTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    TextEditingController controller, {
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _handleSave,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded),
              const SizedBox(width: 12),
              Text("Save Changes"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            foregroundColor: PremiumTheme.secondaryColor,
            side: const BorderSide(color: PremiumTheme.secondaryColor),
          ),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final name = pname.text.trim();
    final description = pdescription.text.trim();
    final priceStr = price.text.trim();
    final quantityStr = quantityController.text.trim();
    final category = categoryController.text.trim();

    if (name.isEmpty || priceStr.isEmpty || quantityStr.isEmpty || category.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Please fill all required fields",
        type: SnackBarType.warning,
      );
      return;
    }

    try {
      final updatedProduct = ProductModel(
        id: product.id,
        name: name,
        sku: description,
        price: double.parse(priceStr),
        quantity: int.parse(quantityStr),
        image: product.image,
        category: category,
        purchasePrice: product.purchasePrice,
        supplierId: product.supplierId,
      );

      await controller.updateProductInDatabase(updatedProduct);

      CustomSnackBar.show(
        context: context,
        message: "Product updated successfully!",
        type: SnackBarType.success,
      );
      Get.back();
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: "Failed to update product. Please try again.",
        type: SnackBarType.error,
      );
    }
  }
}
