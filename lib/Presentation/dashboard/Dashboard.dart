
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';
import 'package:stock_flow/Presentation/dashboard/Quick Action/Add_product.dart';
import 'package:stock_flow/Presentation/dashboard/Quick Action/Manage_Quantity.dart';
import 'package:stock_flow/Presentation/dashboard/Quick Action/Remove_Product.dart';
import 'package:stock_flow/Presentation/dashboard/Quick Action/Select Report/Product_Report.dart';
import 'package:stock_flow/Presentation/dashboard/status/MonthlySales.dart';
import 'package:stock_flow/Presentation/dashboard/status/TodaySales.dart';
import 'package:stock_flow/Presentation/dashboard/status/low_stock_screen.dart';
import 'package:stock_flow/Presentation/dashboard/status/showallproduct.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ProductController productController = Get.put(ProductController());
  final SalesController salesController = Get.put(SalesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white54,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Status",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildAllProductsCard(),
                  _buildLowStockCard(),
                  _buildWeeklySales(),
                  _buildMonthlySales(),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _actionCard(
                    "Add Product",
                    Icons.add,
                    Colors.green,
                        () => Get.to(() => const AddProduct()),
                  ),
                  _actionCard(
                    "Remove Product",
                    Icons.remove_circle_outline,
                    Colors.redAccent,
                        () => Get.to(() => const RemoveProduct()),
                  ),
                  _actionCard(
                    "Product Report",
                    Icons.bar_chart,
                    Colors.blueAccent,
                        () => Get.to(() => const selectProduct()),
                  ),
                  _actionCard(
                    "Manage Quantity",
                    Icons.repeat,
                    Colors.purple,
                        () => Get.to(() => const ManageQuantity()),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Obx(() {
                final recentSales =
                salesController.sales.take(5).toList();

                if (recentSales.isEmpty) {
                  return const Center(
                    child: Text("No recent transactions"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentSales.length,
                  itemBuilder: (context, index) {
                    return _transactionItem(recentSales[index]);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- STATUS CARDS ----------------

  Widget _buildAllProductsCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const ShowAllProduct()),
      child: _statusCard(
        title: "Total Products",
        icon: Icons.inventory,
        color: Colors.green,
        value: Obx(() => Text(
          productController.allProducts.length.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )),

      ),
    );
  }

  Widget _buildLowStockCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const LowStockScreen()),
      child: _statusCard(
        title: "Low Stock",
        icon: Icons.warning,
        color: Colors.deepOrange,
        value: Obx(() => Text(
          productController.lowStockCount.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )),

      ),
    );
  }

  Widget _buildWeeklySales() {
    return GestureDetector(
      onTap: () => Get.to(() => const weeklysales()),
      child: _simpleCard(
        "Weekly Sales",
        Icons.bar_chart,
        Colors.blue,
      ),
    );
  }

  Widget _buildMonthlySales() {
    return GestureDetector(
      onTap: () => Get.to(() => const monthlysales()),
      child: _simpleCard(
        "Monthly Sales",
        Icons.bar_chart,
        Colors.purple,
      ),
    );
  }

  // ---------------- TRANSACTION ITEM ----------------

  Widget _transactionItem(SaleModel sale) {
    if (sale.items.isEmpty) return const SizedBox.shrink();

    String title;
    String subtitle;
    Widget avatar;

    if (sale.items.length == 1) {
      final item = sale.items.first;
      title = item['name'] ?? 'Unknown Product';
      subtitle = "${item['quantity']} units sold";
      final product = productController.allProducts.firstWhereOrNull((p) => p.id == item['id']);
      avatar = CircleAvatar(
        radius: 24,
        backgroundColor: Colors.black,
        child: product != null && product.image.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Image.network(
            product.image,
            fit: BoxFit.cover,
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              color: Colors.white,
            ),
          ),
        )
            : const Icon(Icons.inventory_2, color: Colors.white),
      );
    } else {
      title = "Multiple Items";
      subtitle = "${sale.items.length} products sold";
      avatar = const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.black,
        child: Icon(Icons.shopping_cart, color: Colors.white),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              "+ ₹${sale.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REUSABLE WIDGETS ----------------

  Widget _actionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleCard(String title, IconData icon, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _statusCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget value,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: Colors.white),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          value,
        ],
      ),
    );
  }
}