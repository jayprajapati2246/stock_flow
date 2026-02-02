import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../Data Layear/Controller/sales_controller.dart';
import '../../../Data Layear/Controller/product_controller.dart';
import '../../../Data Layear/Controller/supplier_controller.dart';
import '../../../Data Layear/model/ProductModel/product_model.dart';
import '../../../Data Layear/model/SupplierModel/supplier_model.dart';

class SupplierReport extends StatefulWidget {
  const SupplierReport({super.key});

  @override
  State<SupplierReport> createState() => _SupplierReportState();
}

class _SupplierReportState extends State<SupplierReport> {
  final SupplierController _supplierController = Get.put(SupplierController());
  final ProductController _productController = Get.put(ProductController());
  final SalesController _salesController = Get.put(SalesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Supplier Report",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (_supplierController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (_supplierController.error.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _supplierController.error.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        } else if (_supplierController.suppliers.isEmpty) {
          return const Center(child: Text("No suppliers found."));
        } else {
          final suppliers = _supplierController.suppliers;
          final products = _productController.allProducts;
          final sales = _salesController.sales;

          final Map<String, _SupplierInfo> supplierInfoMap = {};

          for (var s in suppliers) {
            final supplierProducts =
                products.where((p) => p.supplierId == s.id).toList();

            final totalCurrentStockQuantity = supplierProducts.length;

            double allTimePurchaseAmount = 0.0;
            for (final product in supplierProducts) {
              final totalSold = sales
                  .expand((sale) => sale.items)
                  .where((item) => item['id'] == product.id)
                  .fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

              final totalEverPurchased = product.quantity + totalSold;

              allTimePurchaseAmount +=
                  totalEverPurchased * product.purchasePrice;
            }

            supplierInfoMap[s.id!] = _SupplierInfo(
              supplier: s,
              products: supplierProducts,
              totalQuantity: totalCurrentStockQuantity,
              totalPurchase: allTimePurchaseAmount,
            );
          }

          final supplierList = supplierInfoMap.values.toList();

          supplierList.sort(
            (a, b) => a.supplier.name.compareTo(b.supplier.name),
          );

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: supplierList.length,
            itemBuilder: (context, index) {
              final info = supplierList[index];
              return _buildSupplierCard(
                info.supplier,
                info.totalQuantity,
                info.products,
                info.totalPurchase,
              );
            },
          );
        }
      }),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String supplierId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Supplier'),
          content: const Text(
              'Are you sure you want to delete this supplier? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _supplierController.removeSupplier(supplierId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupplierCard(
    Supplier supplier,
    int totalQuantity,
    List<ProductModel> products,
    double totalPurchase,
  ) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            supplier.contact,
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, supplier.id!);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  "Total Product",
                  totalQuantity.toString(),
                  Colors.blue.shade800,
                ),
                _buildStatColumn(
                  "Total Purchases",
                  NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                      .format(totalPurchase),
                  Colors.green.shade800,
                ),
              ],
            ),
            const Divider(height: 24),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                "View Products ",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              children: products.map((product) {
                return ListTile(
                  title: Text(product.name),
                  trailing: Text("Qty: ${product.quantity}"),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
