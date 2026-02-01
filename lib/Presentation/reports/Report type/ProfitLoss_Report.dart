import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfitLossReport extends StatefulWidget {
  const ProfitLossReport({super.key});

  @override
  State<ProfitLossReport> createState() => _ProfitLossReportState();
}

class _ProfitLossReportState extends State<ProfitLossReport> {
  final SalesController _salesController = Get.find<SalesController>();
  final ProductController _productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Profit & Loss Report",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        final sales = _salesController.sales;
        if (sales.isEmpty) {
          return const Center(child: Text("No sales data available."));
        }

        // --- CALCULATIONS ---
        double totalRevenue = 0;
        double totalCost = 0;

        for (final sale in sales) {
          totalRevenue += sale.totalAmount;
          for (final item in sale.items) {
            final product = _productController.allProducts
                .firstWhereOrNull((p) => p.id == item['id']);
            if (product != null) {
              totalCost += product.purchasePrice * (item['quantity'] as num);
            }
          }
        }

        final double netProfit = totalRevenue - totalCost;
        final double totalForChart = totalCost + (netProfit > 0 ? netProfit : 0);

        // Data for Pie Chart
        final List<_ChartData> chartData = [
          _ChartData('Cost', totalCost, Colors.red),
          _ChartData('Profit', netProfit > 0 ? netProfit : 0, Colors.green),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SUMMARY CARDS ---
              Row(
                children: [
                  _buildSummaryCard("💰 Total Revenue",
                      "₹${totalRevenue.toStringAsFixed(2)}", Colors.blue),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                      "📉 Total Cost", "₹${totalCost.toStringAsFixed(2)}", Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                  "🟢 Net Profit", "₹${netProfit.toStringAsFixed(2)}", Colors.green,
                  isFullWidth: true),
              const SizedBox(height: 24),

              // --- VISUAL BREAKDOWN ---
              const Text(
                "Visual Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: SfCircularChart(
                  title: ChartTitle(text: 'Cost vs. Profit Breakdown'),
                  legend: const Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      position: LegendPosition.bottom),
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
                            type: ConnectorType.curve, length: '10%'),
                      ),
                      dataLabelMapper: (_ChartData data, _) {
                        if (totalForChart == 0) return '${data.x}\n0%';
                        final percentage = data.y / totalForChart;
                        return '${data.x}\n${NumberFormat.decimalPercentPattern(decimalDigits: 1).format(percentage)}';
                      },
                      explode: true,
                      explodeIndex: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- DETAILED BREAKDOWN ---
              const Text(
                "Cost & Expense Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBreakdownItem(
                  "Total Purchase Cost", "₹${totalCost.toStringAsFixed(2)}"),
              _buildBreakdownItem(
                  "Total Selling Price (Revenue)", "₹${totalRevenue.toStringAsFixed(2)}"),
              const Divider(thickness: 1.5, height: 20),
              _buildBreakdownItem(
                  "Net Profit & Loss", "₹${netProfit.toStringAsFixed(2)}",
                  isBold: true),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, {bool isFullWidth = false}) {
    final card = Card(
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
    );
    return isFullWidth ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }

  Widget _buildBreakdownItem(String title, String amount, {bool isBold = false}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        trailing: Text(amount,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
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
