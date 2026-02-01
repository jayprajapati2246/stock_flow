import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductReportDetails extends StatelessWidget {
  final ProductModel product;

  const ProductReportDetails({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GetX<SalesController>(
      builder: (salesController) {
        int totalSold = 0;
        double totalRevenue = 0.0;
        double totalProfit = 0.0;
        Map<String, double> monthlySales = {};

        final sales = salesController.sales;

        for (final sale in sales) {
          for (final item in sale.items) {
            if (item['id'] == product.id) {
              final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
              final price = (item['price'] as num).toDouble();
              final cost = product.purchasePrice;

              totalSold += quantity;
              totalRevenue += price * quantity;
              totalProfit += (price - cost) * quantity;

              final monthKey = DateFormat('yyyy-MM').format(sale.date);
              monthlySales.update(monthKey, (value) => value + quantity,
                  ifAbsent: () => quantity.toDouble());
            }
          }
        }

        final sortedKeys = monthlySales.keys.toList()..sort();

        final chartData = sortedKeys.map((key) {
          final date = DateFormat('yyyy-MM').parse(key);
          final displayKey = DateFormat('MMM yyyy').format(date);
          return SalesData(displayKey, monthlySales[key]!);
        }).toList();

        return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF1976D2),
              elevation: 0,
              title: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (product.image.isNotEmpty)
                    //   Center(
                    //     child: Container(
                    //       height: 150,
                    //       width: 150,
                    //       margin: const EdgeInsets.only(bottom: 16),
                    //       decoration: BoxDecoration(
                    //         color: Colors.grey.shade100,
                    //         borderRadius: BorderRadius.circular(12),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.05),
                    //             blurRadius: 10,
                    //             offset: const Offset(0, 4),
                    //           ),
                    //         ],
                    //       ),
                    //       child: ClipRRect(
                    //         borderRadius: BorderRadius.circular(12),
                    //         child: Image.network(
                    //           product.image,
                    //           fit: BoxFit.cover,
                    //           errorBuilder: (context, error, stackTrace) =>
                    //               const Icon(
                    //             Icons.image_not_supported,
                    //             size: 60,
                    //             color: Colors.black54,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    Row(
                      children: [
                        _summaryCard(
                          title: "Available Stock",
                          value: product.quantity.toString(),
                          icon: Icons.inventory,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: "Total Sold",
                          value: totalSold.toString(),
                          icon: Icons.shopping_cart,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _summaryCard(
                          title: "Total Revenue",
                          value: "₹${totalRevenue.toStringAsFixed(0)}",
                          icon: Icons.currency_rupee,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: "Profit",
                          value: "₹${totalProfit.toStringAsFixed(0)}",
                          icon: Icons.trending_up,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Sales Graph (by quantity)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: chartData.isEmpty
                          ? const Center(child: Text("No sales data available."))
                          : SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              series: <CartesianSeries<SalesData, String>>[
                                ColumnSeries<SalesData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (SalesData sales, _) =>
                                      sales.month,
                                  yValueMapper: (SalesData sales, _) =>
                                      sales.sales,
                                  dataLabelSettings:
                                      const DataLabelSettings(isVisible: true),
                                )
                              ],
                            ),
                    ),
                  ],
                )));
      },
    );
  }
}

class SalesData {
  SalesData(this.month, this.sales);

  final String month;
  final double sales;
}

Widget _summaryCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Expanded(
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
