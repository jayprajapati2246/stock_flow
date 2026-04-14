import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesReport extends StatelessWidget {
  const SalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController salesController = Get.find<SalesController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, 
            size: 20
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Sales Analytics",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (salesController.sales.isEmpty) {
          return _buildEmptyState(context);
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Key Statistics"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      context, 
                      "Gross Revenue", 
                      "₹${totalRevenue.toStringAsFixed(0)}", 
                      Icons.payments_rounded, 
                      const Color(0xFF10B981)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _summaryCard(
                      context, 
                      "Total Orders", 
                      totalSales.toString(), 
                      Icons.shopping_bag_rounded, 
                      PremiumTheme.primaryColor
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(context, "Daily Revenue Trend"),
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
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 280,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: DateTimeAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: theme.hintColor),
                      dateFormat: DateFormat.MMMd(),
                    ),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.compactCurrency(locale: 'en', symbol: '₹'),
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: theme.hintColor),
                    ),
                    series: <CartesianSeries>[
                      SplineSeries<_SalesData, DateTime>(
                        dataSource: chartData,
                        xValueMapper: (_SalesData sales, _) => sales.date,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        color: PremiumTheme.primaryColor,
                        width: 4,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          height: 8,
                          width: 8,
                          color: PremiumTheme.primaryColor,
                          borderWidth: 2,
                          borderColor: Colors.white,
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

              const SizedBox(height: 32),
              _buildSectionHeader(context, "Recent Transactions"),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: salesController.sales.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final sale = salesController.sales[index];
                  return _buildSaleCard(context, sale);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
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
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, SaleModel sale) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMd().format(sale.date),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.jm().format(sale.date),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                "₹${sale.totalAmount.toStringAsFixed(0)}",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sale.paymentMethod.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: PremiumTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${sale.items.length} items",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
                ),
              ],
            ),
          ),
          children: [
            const Divider(height: 32),
            ...sale.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, size: 18, color: PremiumTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text("Qty: ${item['quantity']}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                      ],
                    ),
                  ),
                  Text(
                    "₹${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, size: 64, color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text("No sales data recorded yet", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.date, this.sales);
  final DateTime date;
  final double sales;
}
