import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class monthlysales extends StatefulWidget {
  const monthlysales({super.key});

  @override
  State<monthlysales> createState() => _monthlysalesState();
}

class _monthlysalesState extends State<monthlysales> {
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
    // Listen for changes and rebuild
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
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // 1. Filter sales for the current month
    final monthlySales = salesController.sales.where((sale) {
      return !sale.date.isBefore(firstDayOfMonth) &&
          sale.date.isBefore(firstDayOfMonth.add(const Duration(days: 31))); // Approximation for month
    }).toList();

    // 2. Calculate summary values for the current month
    _totalRevenue = monthlySales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    _totalSalesCount = monthlySales.length;
    _avgSaleValue = _totalSalesCount > 0 ? _totalRevenue / _totalSalesCount : 0.0;
    _totalProfit = _calculateTotalProfit(monthlySales);

    // 3. Prepare chart data for the last 6 months
    _chartData = _prepareChartData();
  }

  double _calculateTotalProfit(List<SaleModel> sales) {
    double totalProfit = 0.0;
    if (productController.allProducts.isEmpty) return 0.0;

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

  List<ChartData> _prepareChartData() {
    final now = DateTime.now();
    final Map<String, double> salesByMonth = {};

    // Initialize the last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM').format(month); // e.g., "Jan", "Feb"
      salesByMonth[monthKey] = 0.0;
    }

    // Populate with sales data
    for (final sale in salesController.sales) {
      if (sale.date.isAfter(now.subtract(const Duration(days: 180)))) { // Approx 6 months
        final monthKey = DateFormat('MMM').format(sale.date);
        if (salesByMonth.containsKey(monthKey)) {
          salesByMonth[monthKey] = (salesByMonth[monthKey] ?? 0.0) + sale.totalAmount;
        }
      }
    }

    return salesByMonth.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Monthly Sales",
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
              "Sales Last 6 Months",
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
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
                ),
                 primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.compactSimpleCurrency(locale: 'en_IN'),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartData sales, _) => sales.month,
                    yValueMapper: (ChartData sales, _) => sales.sales,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
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
  ChartData(this.month, this.sales);
  final String month;
  final double sales;
}
