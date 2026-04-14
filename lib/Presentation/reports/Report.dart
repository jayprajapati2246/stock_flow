import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/report_controller.dart';

class Report extends StatelessWidget {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.put(ReportController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Analytics & Reports",
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Gain deep insights into your business performance and inventory health.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildReportCategory(context, "Financial Performance"),
            const SizedBox(height: 12),
            _buildReportItem(
              context,
              icon: Icons.account_balance_wallet_rounded,
              color: PremiumTheme.primaryColor,
              title: "Profit & Loss",
              subtitle: "Revenue, costs, and net profit analysis",
              onTap: controller.goToProfitLossReport,
            ),
            _buildReportItem(
              context,
              icon: Icons.payments_rounded,
              color: const Color(0xFF10B981),
              title: "Sales Report",
              subtitle: "Detailed breakdown of sales performance",
              onTap: controller.goToSalesReport,
            ),
            
            const SizedBox(height: 32),
            _buildReportCategory(context, "Inventory Insights"),
            const SizedBox(height: 12),
            _buildReportItem(
              context,
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFFF59E0B),
              title: "Stock Status",
              subtitle: "Current levels and availability report",
              onTap: controller.goToStockReport,
            ),
            _buildReportItem(
              context,
              icon: Icons.analytics_rounded,
              color: PremiumTheme.accentColor,
              title: "Stock Valuation",
              subtitle: "Total monetary value of current inventory",
              onTap: controller.goToStockValuation,
            ),
            
            const SizedBox(height: 32),
            _buildReportCategory(context, "Partner Analytics"),
            const SizedBox(height: 12),
            _buildReportItem(
              context,
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF0EA5E9),
              title: "Supplier Report",
              subtitle: "Purchase history and supplier performance",
              onTap: controller.goToSupplierReport,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategory(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: theme.brightness == Brightness.dark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.dividerColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
