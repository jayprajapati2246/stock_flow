import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Scack%20bar/snackbar.dart';
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
    pdescription.text = product.sku; // Assuming SKU is used as description
    price.text = product.price.toString();
    categoryController.text = product.category;
    quantityController.text = product.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Edit Product",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 10),
              _buildLabel("Product Name: "),
              _buildInputField(pname, hintText: "Product Name"),
              const SizedBox(height: 12),
              _buildLabel("Product Description: "),
              _buildInputField(pdescription,
                  hintText: "Write Product Description in One Line"),
              const SizedBox(height: 12),
               _buildLabel("Category: "),
              _buildInputField(categoryController, hintText: "Category"),
              const SizedBox(height: 12),
              _buildLabel("Quantity: "),
              _buildInputField(quantityController, hintText: "Quantity", keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildLabel("Product Price: (₹)"),
              _buildInputField(price, hintText: "Product Price (₹)", keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: product.image.isNotEmpty
              ?  Image.network(
            product.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(
              Icons.image_not_supported,
              size: 60,
              color: Colors.black54,
            ),
          ):SizedBox(),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, {
    String? hintText,
    String? trailingText,
    Widget? trailingWidget,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          if (trailingWidget != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: trailingWidget,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final name = pname.text.trim();
                final description = pdescription.text.trim();
                final priceStr = price.text.trim();
                final quantityStr = quantityController.text.trim();
                final category = categoryController.text.trim();

                if (name.isEmpty ||
                    priceStr.isEmpty ||
                    quantityStr.isEmpty ||
                    category.isEmpty) {
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
