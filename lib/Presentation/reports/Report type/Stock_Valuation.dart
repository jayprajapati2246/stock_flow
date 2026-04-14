import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockValuation extends StatelessWidget {
  const StockValuation({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final SalesController salesController = Get.find<SalesController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : PremiumTheme.lightTextPrimary,
              size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Stock Valuation",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (productController.allProducts.isEmpty) {
          return _buildEmptyState(context);
        }

        final products = productController.allProducts;
        double totalStockValue = 0;
        int totalItems = 0;
        for (final product in products) {
          totalStockValue += product.quantity * product.purchasePrice;
          totalItems += product.quantity;
        }

        final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60));
        final recentSales =
            salesController.sales.where((s) => s.date.isAfter(sixtyDaysAgo));
        final soldProductIds = <String>{};
        for (final sale in recentSales) {
          for (final item in sale.items) {
            soldProductIds.add(item['id']);
          }
        }

        double slowStockValue = 0;
        for (final product in products) {
          if (!soldProductIds.contains(product.id) && product.quantity > 0) {
            slowStockValue += product.quantity * product.purchasePrice;
          }
        }

        final fastMovingValue = totalStockValue - slowStockValue;
        final List<_ChartData> chartData = [
          _ChartData('Active Assets', fastMovingValue, const Color(0xFF10B981)),
          _ChartData(
              'Stagnant Stock', slowStockValue, PremiumTheme.secondaryColor),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Asset Portfolio"),
              const SizedBox(height: 16),
              _summaryCard(
                  context,
                  "Net Inventory Value",
                  currencyFormat.format(totalStockValue),
                  Icons.account_balance_wallet_rounded,
                  PremiumTheme.primaryColor,
                  isFullWidth: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _summaryCard(
                          context,
                          "Total Units",
                          NumberFormat.compact().format(totalItems),
                          Icons.layers_rounded,
                          Colors.blueGrey)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _summaryCard(
                          context,
                          "Active Value",
                          currencyFormat.format(fastMovingValue),
                          Icons.bolt_rounded,
                          const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Value Distribution"),
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
                child: SizedBox(
                  height: 260,
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.hintColor),
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
                          textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white
                                  : PremiumTheme.lightTextPrimary),
                        ),
                        dataLabelMapper: (_ChartData data, _) {
                          if (totalStockValue == 0) return '0%';
                          return '${((data.y / totalStockValue) * 100).toStringAsFixed(1)}%';
                        },
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (slowStockValue > 0) ...[
                _buildInsightCard(
                    context,
                    "Inventory Warning",
                    "${currencyFormat.format(slowStockValue)} of your capital is tied up in stock that hasn't moved in 30 days.",
                    PremiumTheme.secondaryColor),
                const SizedBox(height: 32),
              ],
              _buildSectionHeader(context, "Asset Breakdown"),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildValuationItem(context, product);
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

  Widget _summaryCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {bool isFullWidth = false}) {
    final theme = Theme.of(context);
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold, color: theme.hintColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      BuildContext context, String title, String message, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 4),
                Text(message,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuationItem(BuildContext context, dynamic product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalVal = product.quantity * product.purchasePrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                size: 20, color: PremiumTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    "${product.quantity} units @ ₹${product.purchasePrice.toStringAsFixed(0)}",
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold, color: theme.hintColor)),
              ],
            ),
          ),
          Text(
            "₹${totalVal.toStringAsFixed(0)}",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: PremiumTheme.primaryColor),
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
          Icon(Icons.account_balance_rounded,
              size: 64, color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text("No assets to evaluate",
              style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold)),
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
