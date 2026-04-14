import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Presentation/sales/invoice.dart';

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({Key? key}) : super(key: key);

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  late final SalesController controller;
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    controller = Get.find<SalesController>();
  }

  @override
  void dispose() {
    for (final c in _quantityControllers.values) {
      c.dispose();
    }
    _quantityControllers.clear();
    super.dispose();
  }

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
              Text("Filter By", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _filterChip(context, "All", ProductFilter.all),
                  _filterChip(context, "Low Stock", ProductFilter.lowStock),
                ],
              ),
              const SizedBox(height: 24),
              Text("Sort By", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _sortChip(context, "A-Z", ProductSort.aToZ),
                  _sortChip(context, "Z-A", ProductSort.zToA),
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
                    style: OutlinedButton.styleFrom(foregroundColor: PremiumTheme.secondaryColor, side: const BorderSide(color: PremiumTheme.secondaryColor)),
                    child: const Text("Reset Filters"),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, "Sale Details"),
                  const SizedBox(height: 16),
                  Obx(() => _buildInfoCard(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: "Transaction Date",
                    value: DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value),
                    onTap: () => controller.selectDate(context),
                  )),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Search Products"),
                  const SizedBox(height: 16),
                  CommonSearchBar(
                    controller: controller.searchController,
                    hintText: "Search items to add to cart...",
                    onChanged: controller.filterProducts,
                    padding: EdgeInsets.zero,
                    onFilterTap: () => _showFilterMenu(context),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.filteredProducts.isEmpty) {
                      return _buildEmptySearchState(context);
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = controller.filteredProducts[index];
                        final qtyController = _quantityControllers.putIfAbsent(
                          product.id!,
                          () => TextEditingController(text: '1'),
                        );
                        return _buildProductListItem(context, product, qtyController);
                      },
                    );
                  }),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Order Summary"),
                  const SizedBox(height: 16),
                  _buildSummaryCard(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PremiumTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: PremiumTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_calendar_rounded, color: theme.hintColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, product, TextEditingController qtyController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : PremiumTheme.lightBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(product.image, fit: BoxFit.cover),
                  )
                : Icon(Icons.inventory_2_outlined, color: theme.dividerColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("Stock: ${product.quantity}", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: product.quantity < 10 ? PremiumTheme.secondaryColor : const Color(0xFF10B981))),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkBg : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
            ),
            child: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none, 
                contentPadding: EdgeInsets.zero,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: product.quantity > 0
                ? () {
                    final qty = int.tryParse(qtyController.text) ?? 1;
                    controller.addToCart(product, qty);
                    Get.snackbar(
                      "Cart Updated",
                      "${product.name} added to cart",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: theme.cardTheme.color,
                      colorText: theme.textTheme.bodyLarge?.color,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 16,
                      borderWidth: 1,
                      borderColor: theme.dividerColor,
                    );
                  }
                : null,
            icon: Icon(Icons.add_circle_rounded, color: product.quantity > 0 ? PremiumTheme.primaryColor : theme.dividerColor, size: 36),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, "Subtotal", Obx(() => Text("₹${controller.subtotal.toStringAsFixed(2)}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Discount (%)", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? PremiumTheme.darkBg : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: controller.discountController,
                  keyboardType: TextInputType.number,
                  onChanged: controller.updateDiscount,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none, 
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
          _buildSummaryRow(
            context,
            "Total Amount",
            Obx(() => Text("₹${controller.totalAmount.toStringAsFixed(2)}", 
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: PremiumTheme.primaryColor))),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).hintColor)),
        value,
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (controller.cartItems.isEmpty) {
            Get.snackbar("Empty Cart", "Please add some items first", backgroundColor: PremiumTheme.secondaryColor, colorText: Colors.white);
          } else {
            Get.to(() => const InvoicePage());
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_rounded, size: 22),
            const SizedBox(width: 12),
            const Text("Review Invoice"),
            const SizedBox(width: 8),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text("${controller.cartItems.length}", style: const TextStyle(fontSize: 12)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: theme.dividerColor),
          const SizedBox(height: 12),
          Text("No items match your search", style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}
