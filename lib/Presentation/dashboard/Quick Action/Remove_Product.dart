import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/enums.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

class RemoveProduct extends StatefulWidget {
  const RemoveProduct({super.key});

  @override
  State<RemoveProduct> createState() => _RemoveProductState();
}

class _RemoveProductState extends State<RemoveProduct> {
  final ProductController controller = Get.find<ProductController>();
  final TextEditingController searchController = TextEditingController();

  ProductFilter _selectedFilter = ProductFilter.all;
  ProductSort? _selectedSort;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  List<ProductModel> _filteredProducts() {
    final query = searchController.text.toLowerCase();

    List<ProductModel> products = controller.allProducts.where((product) {
      final match = product.name.toLowerCase().contains(query);
      if (_selectedFilter == ProductFilter.lowStock) {
        return match && product.quantity <= 10;
      }
      return match;
    }).toList();

    if (_selectedSort != null) {
      products.sort((a, b) {
        switch (_selectedSort!) {
          case ProductSort.aToZ:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case ProductSort.zToA:
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          case ProductSort.priceHighToLow:
            return b.price.compareTo(a.price);
          case ProductSort.priceLowToHigh:
            return a.price.compareTo(b.price);
        }
      });
    }

    return products;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showFilterMenu(BuildContext context) async {
    final theme = Theme.of(context);
    final value = await showModalBottomSheet<dynamic>(
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
              Text("Management Filters", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Quick Filters"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _buildChoiceChip(context, "All Products", ProductFilter.all, _selectedFilter),
                  _buildChoiceChip(context, "Low Stock Only", ProductFilter.lowStock, _selectedFilter),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Sort Order"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSortChip(context, "Name (A-Z)", ProductSort.aToZ),
                  _buildSortChip(context, "Name (Z-A)", ProductSort.zToA),
                  _buildSortChip(context, "Highest Price", ProductSort.priceHighToLow),
                  _buildSortChip(context, "Lowest Price", ProductSort.priceLowToHigh),
                ],
              ),
              const SizedBox(height: 32),
              if (_selectedSort != null || _selectedFilter != ProductFilter.all)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, MenuAction.clearSort),
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

    if (value == null) return;

    setState(() {
      if (value is ProductFilter) {
        _selectedFilter = value;
      } else if (value is ProductSort) {
        _selectedSort = value;
      } else if (value == MenuAction.clearSort) {
        _selectedSort = null;
        _selectedFilter = ProductFilter.all;
      }
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).hintColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildChoiceChip(BuildContext context, String label, dynamic value, dynamic selectedValue) {
    final isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) Navigator.pop(context, value);
      },
      selectedColor: PremiumTheme.primaryColor,
      labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
  }

  Widget _buildSortChip(BuildContext context, String label, ProductSort value) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) Navigator.pop(context, value);
      },
      selectedColor: PremiumTheme.primaryColor,
      labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
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
          "Cleanup Inventory",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CommonSearchBar(
              controller: searchController,
              hintText: "Search items to remove permanently...",
              onFilterTap: () => _showFilterMenu(context),
            ),
          ),
          Expanded(
            child: Obx(() {
              final products = _filteredProducts();

              if (controller.allProducts.isEmpty) {
                return _buildEmptyState(context, "Your inventory is currently empty.");
              }

              if (products.isEmpty) {
                return _buildEmptyState(context, "No items match your criteria.");
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildProductCard(context, products[index]),
              );
            }),
          ),
          Obx(() => controller.allProducts.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: OutlinedButton(
                    onPressed: () => _showRemoveAllConfirmation(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PremiumTheme.secondaryColor,
                      side: const BorderSide(color: PremiumTheme.secondaryColor, width: 2),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_sweep_rounded),
                        SizedBox(width: 12),
                        Text("CLEAR ENTIRE INVENTORY", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
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
                    child: Image.network(product.image, fit: BoxFit.cover),
                  )
                : Icon(Icons.inventory_2_rounded, color: theme.dividerColor, size: 28),
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
                  "Stock Level: ${product.quantity}",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showSingleRemoveConfirmation(context, product),
            style: IconButton.styleFrom(
              backgroundColor: PremiumTheme.secondaryColor.withOpacity(0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.delete_rounded, color: PremiumTheme.secondaryColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }

  void _showSingleRemoveConfirmation(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("Delete Product?", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        content: Text("Are you sure you want to remove \"${product.name}\"? This action cannot be undone.",
            style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (product.id != null) {
                controller.removeProduct(context, product.id!);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.secondaryColor, minimumSize: const Size(100, 48)),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showRemoveAllConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("Clear Everything?", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: PremiumTheme.secondaryColor)),
        content: const Text("This will permanently remove ALL items from your inventory database. This action is IRREVERSIBLE.",
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Go Back", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              controller.removeAllProducts(context);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.secondaryColor, minimumSize: const Size(120, 48)),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }
}
