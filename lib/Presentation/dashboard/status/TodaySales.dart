import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class weeklysales extends StatefulWidget {
  const weeklysales({super.key});

  @override
  State<weeklysales> createState() => _weeklysalesState();
}

class _weeklysalesState extends State<weeklysales> {
  final SalesController salesController = Get.find<SalesController>();
  final ProductController productController = Get.find<ProductController>();

  double _totalRevenue = 0.0;
  double _totalProfit = 0.0;
  int _totalSalesCount = 0;
  double _avgSaleValue = 0.0;
  List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _processSalesData();
    // Listen for changes in sales from the controller and rebuild the UI
    ever(salesController.sales, (_) {
      if (mounted) {
        setState(() {
          _processSalesData();
        });
      }
    });
  }

  void _processSalesData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final oneWeekAgo = today.subtract(const Duration(days: 6)); // Last 7 days including today

    // 1. Filter sales for the last 7 days
    final weeklySales = salesController.sales.where((sale) {
      return !sale.date.isBefore(oneWeekAgo) &&
          sale.date.isBefore(today.add(const Duration(days: 1)));
    }).toList();

    // 2. Calculate summary values
    _totalRevenue = weeklySales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    _totalSalesCount = weeklySales.length;
    _avgSaleValue = _totalSalesCount > 0 ? _totalRevenue / _totalSalesCount : 0.0;
    _totalProfit = _calculateTotalProfit(weeklySales);

    // 3. Prepare chart data
    _chartData = _prepareChartData(weeklySales, oneWeekAgo);
  }

  double _calculateTotalProfit(List<SaleModel> sales) {
    double totalProfit = 0.0;
    if (productController.allProducts.isEmpty) {
      return 0.0;
    }

    for (final sale in sales) {
      for (final item in sale.items) {
        final product =
            productController.allProducts.firstWhereOrNull((p) => p.id == item['id']);
        if (product != null && product.purchasePrice > 0) {
          final itemPrice = (item['price'] as num? ?? 0.0).toDouble();
          final itemQuantity = (item['quantity'] as num? ?? 0).toInt();
          final itemProfit = (itemPrice - product.purchasePrice) * itemQuantity;
          totalProfit += itemProfit;
        }
      }
    }
    return totalProfit;
  }

  List<ChartData> _prepareChartData(List<SaleModel> sales, DateTime startDate) {
    // Use a LinkedHashMap to preserve insertion order
    final Map<DateTime, double> salesByDate = {};
    for (int i = 0; i < 7; i++) {
      salesByDate[startDate.add(Duration(days: i))] = 0.0;
    }

    // Populate with actual sales data
    for (final sale in sales) {
      final saleDay = DateTime(sale.date.year, sale.date.month, sale.date.day);
      if (salesByDate.containsKey(saleDay)) {
        salesByDate[saleDay] = (salesByDate[saleDay] ?? 0.0) + sale.totalAmount;
      }
    }

    final DateFormat formatter = DateFormat('E'); // "Mon", "Tue"
    return salesByDate.entries
        .map((entry) => ChartData(formatter.format(entry.key), entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Weekly Sales",
          style: TextStyle(
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
            // ----------------- SUMMARY CARDS -----------------
            Row(
              children: [
                _summaryCard(
                  title: "Total Revenue",
                  value: "₹${_totalRevenue.toStringAsFixed(0)}",
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  title: "Total Profit",
                  value: "₹${_totalProfit.toStringAsFixed(0)}",
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _summaryCard(
                  title: "Total Sales",
                  value: _totalSalesCount.toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  title: "Avg. Sale Value",
                  value: "₹${_avgSaleValue.toStringAsFixed(0)}",
                  icon: Icons.show_chart,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ----------------- SALES CHART -----------------
            const Text(
              "Sales Last 7 Days",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.compactSimpleCurrency(locale: 'en_IN'),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartData sales, _) => sales.day,
                    yValueMapper: (ChartData sales, _) => sales.sales,
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.teal,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
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
}

class ChartData {
  ChartData(this.day, this.sales);
  final String day;
  final double sales;
}
