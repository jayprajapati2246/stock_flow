import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
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

    final monthlySales = salesController.sales.where((sale) {
      return !sale.date.isBefore(firstDayOfMonth) &&
          sale.date.isBefore(firstDayOfMonth.add(const Duration(days: 31)));
    }).toList();

    _totalRevenue = monthlySales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    _totalSalesCount = monthlySales.length;
    _avgSaleValue = _totalSalesCount > 0 ? _totalRevenue / _totalSalesCount : 0.0;
    _totalProfit = _calculateTotalProfit(monthlySales);
    _chartData = _prepareChartData();
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

  List<ChartData> _prepareChartData() {
    final now = DateTime.now();
    final Map<String, double> salesByMonth = {};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM').format(month);
      salesByMonth[monthKey] = 0.0;
    }

    for (final sale in salesController.sales) {
      if (sale.date.isAfter(now.subtract(const Duration(days: 180)))) {
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
          "Monthly Performance",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "This Month Summary"),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _summaryCard(context, "Revenue", "₹${_totalRevenue.toStringAsFixed(0)}", Icons.payments_rounded, const Color(0xFF10B981)),
                _summaryCard(context, "Profit", "₹${_totalProfit.toStringAsFixed(0)}", Icons.trending_up_rounded, PremiumTheme.primaryColor),
                _summaryCard(context, "Sales", _totalSalesCount.toString(), Icons.shopping_bag_rounded, const Color(0xFFF59E0B)),
                _summaryCard(context, "Avg. Value", "₹${_avgSaleValue.toStringAsFixed(0)}", Icons.analytics_rounded, PremiumTheme.accentColor),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Sales Trend (6 Months)"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
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
                      xValueMapper: (ChartData sales, _) => sales.month,
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
  ChartData(this.month, this.sales);
  final String month;
  final double sales;
}
