import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductReportDetails extends StatelessWidget {
  final ProductModel product;

  const ProductReportDetails({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          final displayKey = DateFormat('MMM yy').format(date);
          return SalesData(displayKey, monthlySales[key]!);
        }).toList();

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
              "Product Analytics",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(context),
                const SizedBox(height: 32),
                _buildSectionHeader(context, "Key Metrics"),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _summaryCard(context, "Stock Left", product.quantity.toString(), Icons.inventory_2_rounded, PremiumTheme.primaryColor),
                    _summaryCard(context, "Units Sold", totalSold.toString(), Icons.shopping_bag_rounded, const Color(0xFFF59E0B)),
                    _summaryCard(context, "Revenue", "₹${totalRevenue.toStringAsFixed(0)}", Icons.payments_rounded, const Color(0xFF10B981)),
                    _summaryCard(context, "Net Profit", "₹${totalProfit.toStringAsFixed(0)}", Icons.trending_up_rounded, PremiumTheme.accentColor),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, "Demand Analysis"),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sales Volume (Qty)", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          if (chartData.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: PremiumTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text("Monthly", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PremiumTheme.primaryColor)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 240,
                        child: chartData.isEmpty
                            ? _buildEmptyChart(context)
                            : SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                primaryXAxis: CategoryAxis(
                                  majorGridLines: const MajorGridLines(width: 0),
                                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: theme.hintColor),
                                ),
                                primaryYAxis: NumericAxis(
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: theme.hintColor),
                                ),
                                series: <CartesianSeries<SalesData, String>>[
                                  SplineAreaSeries<SalesData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (SalesData sales, _) => sales.month,
                                    yValueMapper: (SalesData sales, _) => sales.sales,
                                    color: PremiumTheme.primaryColor.withOpacity(0.2),
                                    borderColor: PremiumTheme.primaryColor,
                                    borderWidth: 3,
                                    markerSettings: const MarkerSettings(isVisible: true, color: PremiumTheme.primaryColor),
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      textStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : PremiumTheme.lightTextPrimary),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(product.image, fit: BoxFit.cover),
                  )
                : Icon(Icons.inventory_2_rounded, color: PremiumTheme.primaryColor.withOpacity(0.5), size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: PremiumTheme.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
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

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: Theme.of(context).dividerColor),
          const SizedBox(height: 8),
          Text("No sales data recorded yet", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.month, this.sales);
  final String month;
  final double sales;
}
