import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
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
          "Profit & Loss",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        final sales = _salesController.sales;

        if (sales.isEmpty) {
          return _buildEmptyState(context);
        }

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

        final List<_ChartData> chartData = [
          _ChartData('Operational Cost', totalCost, PremiumTheme.secondaryColor),
          _ChartData('Net Margin', netProfit > 0 ? netProfit : 0, const Color(0xFF10B981)),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Performance Overview"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      context,
                      "Gross Revenue",
                      "₹${totalRevenue.toStringAsFixed(0)}",
                      Icons.trending_up_rounded,
                      PremiumTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _summaryCard(
                      context,
                      "Total Cost",
                      "₹${totalCost.toStringAsFixed(0)}",
                      Icons.trending_down_rounded,
                      PremiumTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _summaryCard(
                context,
                "Net Profit Margin",
                "₹${netProfit.toStringAsFixed(0)}",
                Icons.account_balance_wallet_rounded,
                const Color(0xFF10B981),
                isFullWidth: true,
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(context, "Profitability Analysis"),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: SfCircularChart(
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: theme.hintColor),
                        ),
                        series: <CircularSeries>[
                          DoughnutSeries<_ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (_ChartData data, _) => data.x,
                            yValueMapper: (_ChartData data, _) => data.y,
                            pointColorMapper: (_ChartData data, _) => data.color,
                            innerRadius: '70%',
                            explode: true,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : PremiumTheme.lightTextPrimary),
                            ),
                            dataLabelMapper: (_ChartData data, _) {
                              if (totalForChart == 0) return '0%';
                              final percentage = (data.y / totalForChart) * 100;
                              return '${percentage.toStringAsFixed(1)}%';
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(context, "Financial Breakdown"),
              const SizedBox(height: 16),
              _detailRow(context, "Operational \nExpense :-", "₹${totalCost.toStringAsFixed(2)}", Icons.inventory_2_outlined, PremiumTheme.secondaryColor),
              const SizedBox(height: 12),
              _detailRow(context, "Sales \nRevenue :-", "₹${totalRevenue.toStringAsFixed(2)}", Icons.sell_outlined, PremiumTheme.primaryColor),
              const SizedBox(height: 12),
              _detailRow(context, "Projected \nProfit :-", "₹${netProfit.toStringAsFixed(2)}", Icons.savings_outlined, const Color(0xFF10B981), isHighlight: true),
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

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: isFullWidth ? double.infinity : null,
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
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? color.withOpacity(0.05) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlight ? color.withOpacity(0.2) : theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isHighlight ? color : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text("No financial data available yet", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
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
