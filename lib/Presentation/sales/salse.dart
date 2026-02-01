import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Comon part for all/search Product/searchbar.dart';
import 'package:stock_flow/Presentation/sales/invoice.dart';

enum MenuAction { clearSort }

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({Key? key}) : super(key: key);

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  late final SalesController controller;

  /// Quantity controllers only for this page
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    controller = Get.find<SalesController>();
  }

  @override
  void dispose() {
    for (final c in _quantityControllers.values) {
      c.dispose();
    }
    _quantityControllers.clear();
    super.dispose();
  }

  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<dynamic>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<ProductFilter>(
          value: ProductFilter.all,
          child: Text("All Products"),
        ),
        const PopupMenuItem<ProductFilter>(
          value: ProductFilter.lowStock,
          child: Text("Low Stock"),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.aToZ,
          child: Text("Sort by Name (A-Z)"),
        ),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.zToA,
          child: Text("Sort by Name (Z-A)"),
        ),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.priceHighToLow,
          child: Text("Sort by Price (High-Low)"),
        ),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.priceLowToHigh,
          child: Text("Sort by Price (Low-High)"),
        ),
        if (controller.selectedSort.value != null) ...[
          const PopupMenuDivider(),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.clearSort,
            child: Text("Clear Sort"),
          ),
        ]
      ],
    ).then((value) {
      if (value != null) {
        if (value is ProductFilter) {
          controller.setFilter(value);
        } else if (value is ProductSort) {
          controller.setSort(value);
        } else if (value is MenuAction && value == MenuAction.clearSort) {
          controller.setSort(null);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -------- SALE DATE --------
            _buildSection(
              title: "Sale Details",
              child: Obx(
                () => _buildInfoTile(
                  icon: Icons.calendar_today,
                  label: "Sale Date",
                  value: DateFormat('MMMM dd, yyyy')
                      .format(controller.selectedDate.value),
                  onTap: () => controller.selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // -------- ADD PRODUCTS --------
            _buildSection(
              title: "Add Products",
              child: Column(
                children: [
                  Builder(builder: (context) {
                    return CommonSearchBar(
                      controller: controller.searchController,
                      hintText: "Search product...",
                      onChanged: controller.filterProducts,
                      padding: EdgeInsets.zero,
                      iconSize: 24,
                      height: 48,
                      onFilterTap: () {
                        _showFilterMenu(context);
                      },
                    );
                  }),
                  const Divider(height: 20),
                  Obx(() {
                    if (controller.filteredProducts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("No products found")),
                      );
                    }
                    return Column(
                      children: controller.filteredProducts.map((product) {
                        final qtyController = _quantityControllers.putIfAbsent(
                          product.id!,
                          () => TextEditingController(text: '1'),
                        );
                        return _buildProductTile(product, qtyController);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------- ORDER SUMMARY --------
            _buildSection(
              title: "Order Summary",
              child: Column(
                children: [
                  Obx(() => _buildSummaryRow("Subtotal", controller.subtotal)),
                  const SizedBox(height: 10),
                  _buildDiscountRow(),
                  const Divider(height: 30),
                  Obx(() => _buildSummaryRow(
                        "Total",
                        controller.totalAmount,
                        isTotal: true,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -------- PROCEED --------
            ElevatedButton(
              onPressed: () {
                if (controller.cartItems.isEmpty) {
                  Get.snackbar(
                    "Cart Empty",
                    "Please add at least one product",
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red.shade600,
                    colorText: Colors.white,
                    borderRadius: 14,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    icon: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    shouldIconPulse: false,
                    boxShadows: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  );
                } else {
                  Get.to(() => const InvoicePage());
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                "Proceed to Invoice",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.arrow_drop_down) : null,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildProductTile(product, TextEditingController qtyController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text("Stock: ${product.quantity}",
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            height: 35,
            child: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: product.quantity > 0
                ? () {
                    final qty = int.tryParse(qtyController.text) ?? 1;
                    controller.addToCart(product, qty);
                    Get.snackbar(
                      "Added",
                      "${product.name} added to cart",
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      borderRadius: 18,
                      margin: const EdgeInsets.all(14),
                      boxShadows: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    );
                  }
                : null,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          "₹ ${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 20 : 16,
            color: isTotal ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Discount (%)", style: TextStyle(color: Colors.grey.shade600)),
        SizedBox(
          width: 70,
          height: 40,
          child: TextField(
            controller: controller.discountController,
            keyboardType: TextInputType.number,
            onChanged: controller.updateDiscount,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
