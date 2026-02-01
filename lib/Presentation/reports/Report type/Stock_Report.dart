import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Manage_Quantity.dart';

enum StockSort { quantityAsc, quantityDesc, nameAsc, nameDesc }

class StockReport extends StatefulWidget {
  const StockReport({super.key});

  @override
  State<StockReport> createState() => _StockReportState();
}

class _StockReportState extends State<StockReport> {
  final ProductController _productController = Get.find<ProductController>();
  StockSort _currentSort = StockSort.quantityAsc;

  List<ProductModel> get _sortedProducts {
    final products = List<ProductModel>.from(_productController.allProducts);

    products.sort((a, b) {
      switch (_currentSort) {
        case StockSort.quantityAsc:
          return a.quantity.compareTo(b.quantity);
        case StockSort.quantityDesc:
          return b.quantity.compareTo(a.quantity);
        case StockSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case StockSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Stock Report",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        // Recalculate summary stats based on controller data
        final products = _productController.allProducts;
        final totalProducts = products.length;
        final outOfStock = products.where((p) => p.quantity == 0).length;
        final lowStock = products.where((p) => p.quantity > 0 && p.quantity <= 5).length;
        final inStock = totalProducts - outOfStock - lowStock;

        return Column(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSummaryCard("📦 Total Products", totalProducts.toString(), Colors.blueGrey),
                      const SizedBox(width: 16),
                      _buildSummaryCard("🟢 In Stock", inStock.toString(), Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryCard("🔴 Out of Stock", outOfStock.toString(), Colors.red),
                      const SizedBox(width: 16),
                      _buildSummaryCard("🟡 Low Stock", lowStock.toString(), Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stock List",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildSortDropdown(),
                ],
              ),
            ),
            Expanded(
              child: _sortedProducts.isEmpty
                  ? const Center(
                      child: Text(
                        "No products found.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _sortedProducts.length,
                      itemBuilder: (context, index) {
                        final product = _sortedProducts[index];
                        String status;
                        if (product.quantity == 0) {
                          status = "Empty";
                        } else if (product.quantity <= 5) {
                          status = "Low";
                        } else {
                          status = "Good";
                        }
                        return _buildStockListItem(context, product, status);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<StockSort>(
      value: _currentSort,
      icon: const Icon(Icons.sort),
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(
          value: StockSort.quantityAsc,
          child: Text("Sort by Quantity (Asc)"),
        ),
        DropdownMenuItem(
          value: StockSort.quantityDesc,
          child: Text("Sort by Quantity (Desc)"),
        ),
        DropdownMenuItem(
          value: StockSort.nameAsc,
          child: Text("Sort by Name (A-Z)"),
        ),
        DropdownMenuItem(
          value: StockSort.nameDesc,
          child: Text("Sort by Name (Z-A)"),
        ),
      ],
      onChanged: (StockSort? newValue) {
        if (newValue != null) {
          setState(() {
            _currentSort = newValue;
          });
        }
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockListItem(BuildContext context, ProductModel product, String status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case "Good":
        statusColor = Colors.green;
        statusText = "In Stock";
        break;
      case "Low":
        statusColor = Colors.orange;
        statusText = "Low Stock";
        break;
      case "Empty":
      default:
        statusColor = Colors.red;
        statusText = "Out of Stock";
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Available: ${product.quantity}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            // IconButton(
            //   icon: const Icon(Icons.edit, size: 20),
            //   // onPressed: () {
            //   //   Get.to(() => ManageQuantity(product: product));
            //   // },
            //   color: Colors.blue,
            // ),
          ],
        ),
      ),
    );
  }
}
