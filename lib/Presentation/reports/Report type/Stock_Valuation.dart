import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockValuation extends StatelessWidget {
  const StockValuation({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final SalesController salesController = Get.find<SalesController>();
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Stock Valuation",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (productController.allProducts.isEmpty) {
          return const Center(child: Text("No products in inventory."));
        }

        // --- CALCULATIONS ---
        final products = productController.allProducts;

        // 1. Total Stock Value & Total Items
        double totalStockValue = 0;
        int totalItems = 0;
        for (final product in products) {
          totalStockValue += product.quantity * product.purchasePrice;
          totalItems += product.quantity;
        }

        // 2. Slow/Dead vs. Fast-Moving Stock
        final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60));
        final recentSales =
            salesController.sales.where((s) => s.date.isAfter(sixtyDaysAgo));

        final soldProductIds = <String>{};
        for (final sale in recentSales) {
          for (final item in sale.items) {
            soldProductIds.add(item['id']);
          }
        }

        double slowStockValue = 0;
        final slowMovingProducts = products
            .where((p) => !soldProductIds.contains(p.id) && p.quantity > 0)
            .toList();
        for (final product in slowMovingProducts) {
          slowStockValue += product.quantity * product.purchasePrice;
        }

        final fastMovingValue = totalStockValue - slowStockValue;

        // 3. Pie Chart Data
        final List<_ChartData> chartData = [
          _ChartData('Fast-Moving', fastMovingValue, Colors.green),
          _ChartData('Slow/Dead Stock', slowStockValue, Colors.red),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SUMMARY CARDS ---
              _buildSummaryCard(
                  "💰 Total Stock Value",
                  currencyFormat.format(totalStockValue),
                  Colors.blueAccent,
                  isFullWidth: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard("📦 Total Items",
                        NumberFormat.compact().format(totalItems), Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                        "🟢 Fast-Moving Value",
                        currencyFormat.format(fastMovingValue),
                        Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                  "🔴 Slow/Dead Stock Value",
                  currencyFormat.format(slowStockValue),
                  Colors.red,
                  isFullWidth: true),
              const SizedBox(height: 24),

              // --- PIE CHART ---
              const Text("Stock Distribution",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (totalStockValue > 0)
                SizedBox(
                  height: 220,
                  child: SfCircularChart(
                    title: ChartTitle(text: 'Stock Value Distribution'),
                    legend: const Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      position: LegendPosition.bottom,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries>[
                      DoughnutSeries<_ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                        pointColorMapper: (_ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          connectorLineSettings: ConnectorLineSettings(
                            type: ConnectorType.curve,
                            length: '10%',
                          ),
                        ),
                        dataLabelMapper: (_ChartData data, _) {
                          if (totalStockValue == 0) return '${data.x}\n0%';
                          final percentage = data.y / totalStockValue;
                          return '${data.x}\n${NumberFormat.decimalPercentPattern(decimalDigits: 1).format(percentage)}';
                        },
                        explode: true,
                        explodeIndex: 1, // Explode the 'Slow/Dead Stock' slice
                      )
                    ],
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text("No stock value to display")),
                ),
              const SizedBox(height: 24),

              // --- PRODUCT LIST ---
              const Text("Product-wise Valuation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductListItem(
                    product.name,
                    product.quantity,
                    product.purchasePrice,
                    product.quantity * product.purchasePrice,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- SMART INSIGHT ---
              if (slowStockValue > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${currencyFormat.format(slowStockValue)} worth of stock has not moved in 60 days",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// Summary Card
  Widget _buildSummaryCard(String title, String value, Color color,
      {bool isFullWidth = false}) {
    final card = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
    return isFullWidth ? SizedBox(width: double.infinity, child: card) : card;
  }

  /// Product Item
  Widget _buildProductListItem(
      String productName, int quantity, num price, num totalValue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.inventory_2_outlined),
        ),
        title:
            Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "$quantity x ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(price)}"),
        trailing: Text(
            NumberFormat.currency(locale: 'en_IN', symbol: '₹')
                .format(totalValue),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
