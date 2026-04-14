import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/supplier_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Data%20Layear/model/SupplierModel/supplier_model.dart';

class SupplierReport extends StatefulWidget {
  const SupplierReport({super.key});

  @override
  State<SupplierReport> createState() => _SupplierReportState();
}

class _SupplierReportState extends State<SupplierReport> {
  final SupplierController _supplierController = Get.put(SupplierController());
  final ProductController _productController = Get.find<ProductController>();
  final SalesController _salesController = Get.find<SalesController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
          "Supplier Directory",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (_supplierController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: PremiumTheme.primaryColor));
        } else if (_supplierController.error.value != null) {
          return _buildErrorState(context, _supplierController.error.value!);
        } else if (_supplierController.suppliers.isEmpty) {
          return _buildEmptyState(context);
        } else {
          final suppliers = _supplierController.suppliers;
          final products = _productController.allProducts;
          final sales = _salesController.sales;

          final List<_SupplierInfo> supplierList = suppliers.map((s) {
            final List<ProductModel> supplierProducts = products.where((p) => p.supplierId == s.id).toList();
            double allTimePurchaseAmount = 0.0;
            for (final product in supplierProducts) {
              final totalSold = sales
                  .expand((sale) => sale.items)
                  .where((item) => item['id'] == product.id)
                  .fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
              allTimePurchaseAmount += (product.quantity + totalSold) * product.purchasePrice;
            }
            return _SupplierInfo(
              supplier: s,
              products: supplierProducts,
              totalQuantity: supplierProducts.length,
              totalPurchase: allTimePurchaseAmount,
            );
          }).toList();

          supplierList.sort((a, b) => a.supplier.name.compareTo(b.supplier.name));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: supplierList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final info = supplierList[index];
              return _buildSupplierCard(context, info);
            },
          );
        }
      }),
    );
  }

  Widget _buildSupplierCard(BuildContext context, _SupplierInfo info) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.business_rounded, color: PremiumTheme.primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.supplier.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_rounded, color: theme.hintColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            info.supplier.contact,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmationDialog(context, info.supplier.id!),
                  style: IconButton.styleFrom(
                    backgroundColor: PremiumTheme.secondaryColor.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, color: PremiumTheme.secondaryColor, size: 20),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
              border: Border.symmetric(horizontal: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(context, "CATALOG", "${info.totalQuantity} items", PremiumTheme.primaryColor),
                Container(width: 1, height: 30, color: theme.dividerColor),
                _buildStat(context, "TOTAL TRADE", NumberFormat.compactSimpleCurrency(locale: 'en_IN').format(info.totalPurchase), const Color(0xFF10B981)),
              ],
            ),
          ),

          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
              title: Text(
                "Supplied Products",
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: PremiumTheme.primaryColor),
              ),
              children: info.products.map((product) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    child: product.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, size: 20),
                            ),
                          )
                        : const Icon(Icons.inventory_2_outlined, size: 20),
                  ),
                  title: Text(product.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    NumberFormat.simpleCurrency(locale: 'en_IN').format(product.price),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PremiumTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Qty: ${product.quantity}",
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: product.quantity <= 5 ? PremiumTheme.secondaryColor : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Theme.of(context).hintColor, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined, size: 64, color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text("No suppliers found", style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: PremiumTheme.secondaryColor),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String supplierId) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("Remove Supplier?", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        content: const Text("This will remove the supplier record. Associated products will remain in inventory."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              _supplierController.removeSupplier(supplierId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.secondaryColor, minimumSize: const Size(100, 48)),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _SupplierInfo {
  final Supplier supplier;
  final List<ProductModel> products;
  final int totalQuantity;
  final double totalPurchase;

  _SupplierInfo({
    required this.supplier,
    required this.products,
    required this.totalQuantity,
    required this.totalPurchase,
  });
}
