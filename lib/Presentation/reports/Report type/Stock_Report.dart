import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

enum StockSort { quantityAsc, quantityDesc, nameAsc, nameDesc }

class StockReport extends StatefulWidget {
  const StockReport({super.key});

  @override
  State<StockReport> createState() => _StockReportState();
}

class _StockReportState extends State<StockReport> {
  final ProductController _productController = Get.find<ProductController>();
  StockSort _currentSort = StockSort.quantityAsc;

  List<ProductModel> get _sortedProducts {
    final products = List<ProductModel>.from(_productController.allProducts);

    products.sort((a, b) {
      switch (_currentSort) {
        case StockSort.quantityAsc:
          return a.quantity.compareTo(b.quantity);
        case StockSort.quantityDesc:
          return b.quantity.compareTo(a.quantity);
        case StockSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case StockSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });
    return products;
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
            color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, 
            size: 20
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Inventory Health",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        final products = _productController.allProducts;
        final totalProducts = products.length;
        final outOfStock = products.where((p) => p.quantity == 0).length;
        final lowStock = products.where((p) => p.quantity > 0 && p.quantity <= 10).length;
        final healthyStock = totalProducts - outOfStock - lowStock;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, "Global Stock Status"),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _statusCard(context, "Total SKUs", totalProducts.toString(), Icons.inventory_2_rounded, PremiumTheme.primaryColor),
                        _statusCard(context, "Healthy", healthyStock.toString(), Icons.check_circle_rounded, const Color(0xFF10B981)),
                        _statusCard(context, "Low Stock", lowStock.toString(), Icons.warning_amber_rounded, const Color(0xFFF59E0B)),
                        _statusCard(context, "Out of Stock", outOfStock.toString(), Icons.error_outline_rounded, PremiumTheme.secondaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(context, "Asset Details"),
                    _buildSortButton(context),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: _sortedProducts.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState(context))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildStockCard(context, _sortedProducts[index]),
                        ),
                        childCount: _sortedProducts.length,
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
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

  Widget _statusCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
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
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<StockSort>(
      onSelected: (sort) => setState(() => _currentSort = sort),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      offset: const Offset(0, 45),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: PremiumTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded, size: 16, color: PremiumTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              "SORT",
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: PremiumTheme.primaryColor),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildSortItem(StockSort.quantityAsc, "Low to High Qty"),
        _buildSortItem(StockSort.quantityDesc, "High to Low Qty"),
        _buildSortItem(StockSort.nameAsc, "Name: A to Z"),
        _buildSortItem(StockSort.nameDesc, "Name: Z to A"),
      ],
    );
  }

  PopupMenuItem<StockSort> _buildSortItem(StockSort value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStockCard(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color statusColor;
    String statusText;
    if (product.quantity == 0) {
      statusColor = PremiumTheme.secondaryColor;
      statusText = "OUT OF STOCK";
    } else if (product.quantity <= 10) {
      statusColor = const Color(0xFFF59E0B);
      statusText = "LOW STOCK";
    } else {
      statusColor = const Color(0xFF10B981);
      statusText = "STABLE";
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(product.image, fit: BoxFit.cover))
                : Icon(Icons.inventory_2_rounded, color: theme.dividerColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Count: ${product.quantity}",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
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
          Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text("No products tracked yet", style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
