import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Data%20Layear/model/SaleModel/sale_model.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Add_product.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Manage_Quantity.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Remove_Product.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Select%20Report/Product_Report.dart';
import 'package:stock_flow/Presentation/dashboard/status/MonthlySales.dart';
import 'package:stock_flow/Presentation/dashboard/status/TodaySales.dart';
import 'package:stock_flow/Presentation/dashboard/status/low_stock_screen.dart';
import 'package:stock_flow/Presentation/dashboard/status/showallproduct.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ProductController productController = Get.put(ProductController());
  final SalesController salesController = Get.put(SalesController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic if needed
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Overview", null),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  _buildStatusCard(
                    context,
                    "Total Products",
                    Obx(() => Text(productController.allProducts.length.toString(),
                        style: theme.textTheme.displaySmall?.copyWith(fontSize: 22))),
                    Icons.inventory_2_rounded,
                    PremiumTheme.primaryColor,
                    () => Get.to(() => const ShowAllProduct()),
                  ),
                  _buildStatusCard(
                    context,
                    "Low Stock",
                    Obx(() => Text(productController.lowStockCount.toString(),
                        style: theme.textTheme.displaySmall?.copyWith(fontSize: 22))),
                    Icons.warning_amber_rounded,
                    PremiumTheme.secondaryColor,
                    () => Get.to(() => const LowStockScreen()),
                  ),
                  _buildStatusCard(
                    context,
                    "Weekly Sales",
                    const Icon(Icons.trending_up_rounded, color: Colors.white, size: 22),
                    Icons.bar_chart_rounded,
                    const Color(0xFF10B981),
                    () => Get.to(() => const weeklysales()),
                    useCustomIcon: true,
                  ),
                  _buildStatusCard(
                    context,
                    "Monthly Sales",
                    const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                    Icons.analytics_rounded,
                    const Color(0xFFF59E0B),
                    () => Get.to(() => const monthlysales()),
                    useCustomIcon: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Quick Actions", null),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    _buildQuickAction(
                      context,
                      "Add",
                      Icons.add_circle_outline_rounded,
                      PremiumTheme.primaryColor,
                      () => Get.to(() => const AddProduct()),
                    ),
                    _buildQuickAction(
                      context,
                      "Remove",
                      Icons.remove_circle_outline_rounded,
                      PremiumTheme.secondaryColor,
                      () => Get.to(() => const RemoveProduct()),
                    ),
                    _buildQuickAction(
                      context,
                      "Report",
                      Icons.description_outlined,
                      const Color(0xFF10B981),
                      () => Get.to(() => const selectProduct()),
                    ),
                    _buildQuickAction(
                      context,
                      "Manage",
                      Icons.tune_rounded,
                      PremiumTheme.accentColor,
                      () => Get.to(() => const ManageQuantity()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(
                context, 
                "Recent Transactions", 
                () {},
              ),
              const SizedBox(height: 16),
              Obx(() {
                final recentSales = salesController.sales.take(5).toList();
                if (recentSales.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentSales.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildTransactionItem(context, recentSales[index]),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onAction, {String actionLabel = "See All"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
          ),
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: GoogleFonts.inter(
                color: PremiumTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context, 
    String title, 
    Widget value, 
    IconData icon, 
    Color color, 
    VoidCallback onTap,
    {bool useCustomIcon = false}
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: value,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? PremiumTheme.darkTextPrimary : PremiumTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, SaleModel sale) {
    if (sale.items.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isMultiple = sale.items.length > 1;
    final item = sale.items.first;
    final title = isMultiple ? "Bulk Sale" : (item['name'] ?? 'Product');
    
    final dateStr = DateFormat('dd MMM').format(sale.date);
    final subtitle = isMultiple ? "${sale.items.length} items • $dateStr" : "${item['quantity']} units • $dateStr";
    
    String? imageUrl;
    if (!isMultiple) {
      final product = productController.allProducts.firstWhereOrNull((p) => p.id == item['id']);
      if (product != null && product.image.isNotEmpty) {
        imageUrl = product.image;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PremiumTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: (isMultiple || imageUrl == null)
              ? Icon(
                  isMultiple ? Icons.auto_awesome_motion_rounded : Icons.inventory_2_rounded,
                  color: PremiumTheme.primaryColor,
                  size: 20,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.inventory_2_rounded,
                      color: PremiumTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "₹${sale.totalAmount.toStringAsFixed(0)}",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "PAID",
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            "No transactions yet", 
            style: theme.textTheme.titleMedium?.copyWith(
              color: PremiumTheme.lightTextSecondary,
            )
          ),
        ],
      ),
    );
  }
}
