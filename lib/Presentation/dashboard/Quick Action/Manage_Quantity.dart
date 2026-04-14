import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/dashboard_Manage_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

enum MenuAction { clearSort }

class ManageQuantity extends StatefulWidget {
  const ManageQuantity({super.key});

  @override
  State<ManageQuantity> createState() => _ManageQuantityState();
}

class _ManageQuantityState extends State<ManageQuantity> {
  final DashboardManageController controller = Get.put(DashboardManageController());
  final Map<String, TextEditingController> adjustmentControllers = {};

  void _showFilterMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text("Filter & Sort", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Filter By Status"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _filterChip(context, "All Products", ProductFilter.all),
                  _filterChip(context, "Low Stock", ProductFilter.lowStock),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Sort By"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _sortChip(context, "Name (A-Z)", ProductSort.aToZ),
                  _sortChip(context, "Name (Z-A)", ProductSort.zToA),
                  _sortChip(context, "Price: High-Low", ProductSort.priceHighToLow),
                  _sortChip(context, "Price: Low-High", ProductSort.priceLowToHigh),
                ],
              ),
              const SizedBox(height: 32),
              if (controller.selectedSort.value != null || controller.selectedFilter.value != ProductFilter.all)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.setSort(null);
                      controller.setFilter(ProductFilter.all);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PremiumTheme.secondaryColor,
                      side: const BorderSide(color: PremiumTheme.secondaryColor),
                    ),
                    child: const Text("Reset All Filters"),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: theme.brightness == Brightness.dark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, ProductFilter filter) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filter;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.setFilter(filter);
            Navigator.pop(context);
          }
        },
        selectedColor: PremiumTheme.primaryColor,
        labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      );
    });
  }

  Widget _sortChip(BuildContext context, String label, ProductSort sort) {
    return Obx(() {
      final isSelected = controller.selectedSort.value == sort;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.setSort(sort);
            Navigator.pop(context);
          }
        },
        selectedColor: PremiumTheme.primaryColor,
        labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      );
    });
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
          "Manage Stock",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CommonSearchBar(
              controller: controller.manageQuantitySearchController,
              hintText: "Search products to adjust quantity...",
              onFilterTap: () => _showFilterMenu(context),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  String title = controller.selectedFilter.value == ProductFilter.lowStock 
                      ? "Low Stock" : "Total Products";
                  return Text(
                    "$title: ${controller.filteredProducts.length}",
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                  );
                }),
                Obx(() => controller.selectedSort.value != null 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: PremiumTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Sorted", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PremiumTheme.primaryColor)),
                    )
                  : const SizedBox.shrink()),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              final products = controller.filteredProducts;

              if (products.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final adjustment = controller.getAdjustment(product.id!);
                  return _quantityCard(context, product, adjustment);
                },
              );
            }),
          ),

          Obx(() {
            return controller.productController.allProducts.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: ElevatedButton(
                      onPressed: controller.productController.isLoading.value
                          ? null
                          : () => controller.saveChanges(context),
                      child: controller.productController.isLoading.value
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded),
                                const SizedBox(width: 12),
                                const Text("Save Changes"),
                              ],
                            ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _quantityCard(BuildContext context, ProductModel product, int adjustment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final TextEditingController textController = getController(product.id!, adjustment);

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
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image_outlined, color: theme.dividerColor),
                    ),
                  )
                : Icon(Icons.inventory_2_rounded, color: PremiumTheme.primaryColor.withOpacity(0.5), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  "Current: ${product.quantity}",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: theme.hintColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PremiumTheme.primaryColor.withOpacity(0.5), width: 1.5),
            ),
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: PremiumTheme.primaryColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                controller.updateAdjustment(product.id!, intValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text("No products found", style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }

  TextEditingController getController(String productId, int value) {
    if (!adjustmentControllers.containsKey(productId)) {
      adjustmentControllers[productId] = TextEditingController(text: value.toString());
    }
    return adjustmentControllers[productId]!;
  }
}
