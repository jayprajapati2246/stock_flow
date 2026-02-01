import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesReport extends StatelessWidget {
  const SalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController salesController = Get.find<SalesController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Sales Report",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (salesController.sales.isEmpty) {
          return const Center(
            child: Text("No sales data available.", style: TextStyle(fontSize: 16)),
          );
        }

        // --- AGGREGATE SALES DATA FOR CHART ---
        final Map<DateTime, double> dailySales = {};
        for (final sale in salesController.sales) {
          final date = DateTime(sale.date.year, sale.date.month, sale.date.day);
          dailySales.update(date, (value) => value + sale.totalAmount, ifAbsent: () => sale.totalAmount);
        }

        final chartData = dailySales.entries.map((e) => _SalesData(e.key, e.value)).toList();
        chartData.sort((a, b) => a.date.compareTo(b.date));

        final double totalRevenue = salesController.sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
        final int totalSales = salesController.sales.length;

        return SingleChildScrollView(
          child: Column(
            children: [
              // --- SUMMARY HEADERS ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _buildSummaryCard("Total Revenue", "₹${totalRevenue.toStringAsFixed(2)}", Colors.green),
                    const SizedBox(width: 16),
                    _buildSummaryCard("Total Sales", totalSales.toString(), Colors.blue),
                  ],
                ),
              ),

              // --- SALES CHART ---
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Daily Sales Revenue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    dateFormat: DateFormat.MMMd(),
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compactCurrency(locale: 'en', symbol: '₹'),
                  ),
                  series: <CartesianSeries>[
                    LineSeries<_SalesData, DateTime>(
                      dataSource: chartData,
                      xValueMapper: (_SalesData sales, _) => sales.date,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                      markerSettings: const MarkerSettings(isVisible: true),
                       dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                          final value = (data as _SalesData).sales;
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              NumberFormat.compactCurrency(locale: 'en', symbol: '₹', decimalDigits: 0).format(value),
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),

              // --- SALES LIST ---
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: salesController.sales.length,
                itemBuilder: (context, index) {
                  final sale = salesController.sales[index];
                  return _buildSaleCard(sale);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.yMMMd().add_jm().format(sale.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("₹${sale.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Payment: ${sale.paymentMethod}", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
            const Divider(height: 20),
            const Text("Items Sold:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text("${item['name']} (x${item['quantity']})")),
                      Text("₹${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.date, this.sales);
  final DateTime date;
  final double sales;
}
