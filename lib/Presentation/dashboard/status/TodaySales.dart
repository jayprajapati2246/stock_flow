import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
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
    final oneWeekAgo = today.subtract(const Duration(days: 6));

    final weeklySales = salesController.sales.where((sale) {
      return !sale.date.isBefore(oneWeekAgo) &&
          sale.date.isBefore(today.add(const Duration(days: 1)));
    }).toList();

    _totalRevenue = weeklySales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    _totalSalesCount = weeklySales.length;
    _avgSaleValue = _totalSalesCount > 0 ? _totalRevenue / _totalSalesCount : 0.0;
    _totalProfit = _calculateTotalProfit(weeklySales);
    _chartData = _prepareChartData(weeklySales, oneWeekAgo);
  }

  double _calculateTotalProfit(List<SaleModel> sales) {
    double totalProfit = 0.0;
    if (productController.allProducts.isEmpty) return 0.0;

    for (final sale in sales) {
      for (final item in sale.items) {
        final product = productController.allProducts.firstWhereOrNull((p) => p.id == item['id']);
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
    final Map<DateTime, double> salesByDate = {};
    for (int i = 0; i < 7; i++) {
      salesByDate[startDate.add(Duration(days: i))] = 0.0;
    }

    for (final sale in sales) {
      final saleDay = DateTime(sale.date.year, sale.date.month, sale.date.day);
      if (salesByDate.containsKey(saleDay)) {
        salesByDate[saleDay] = (salesByDate[saleDay] ?? 0.0) + sale.totalAmount;
      }
    }

    final DateFormat formatter = DateFormat('E');
    return salesByDate.entries
        .map((entry) => ChartData(formatter.format(entry.key), entry.value))
        .toList();
  }

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
              color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Weekly Analytics",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "Last 7 Days Metrics"),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _summaryCard(context, "Revenue", "₹${_totalRevenue.toStringAsFixed(0)}", Icons.account_balance_rounded, const Color(0xFF10B981)),
                _summaryCard(context, "Est. Profit", "₹${_totalProfit.toStringAsFixed(0)}", Icons.auto_graph_rounded, PremiumTheme.primaryColor),
                _summaryCard(context, "Transactions", _totalSalesCount.toString(), Icons.receipt_long_rounded, const Color(0xFFF59E0B)),
                _summaryCard(context, "Average Order", "₹${_avgSaleValue.toStringAsFixed(0)}", Icons.shopping_basket_rounded, PremiumTheme.accentColor),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Daily Sales Volume"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: SizedBox(
                height: 280,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: theme.hintColor),
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compactSimpleCurrency(locale: 'en_IN'),
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: theme.hintColor),
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<ChartData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ChartData sales, _) => sales.day,
                      yValueMapper: (ChartData sales, _) => sales.sales,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      color: PremiumTheme.primaryColor,
                      gradient: LinearGradient(
                        colors: [PremiumTheme.primaryColor, PremiumTheme.primaryColor.withOpacity(0.7)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : PremiumTheme.lightTextPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.day, this.sales);
  final String day;
  final double sales;
}
