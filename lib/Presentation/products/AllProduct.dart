import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Presentation/products/Edit_Product/Edit_product.dart';

enum ProductFilter { all, lowStock }

enum ProductSort { aToZ, zToA, priceHighToLow, priceLowToHigh }

enum MenuAction { clearSort }

class AllProduct extends StatefulWidget {
  const AllProduct({super.key});

  @override
  State<AllProduct> createState() => _AllProductState();
}

class _AllProductState extends State<AllProduct> {
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

  List<ProductModel> _getFilteredProducts() {
    final query = searchController.text.toLowerCase();

    List<ProductModel> products = controller.allProducts.where((product) {
      final nameMatch = product.name.toLowerCase().contains(query);
      if (_selectedFilter == ProductFilter.lowStock) {
        return nameMatch && product.quantity <= 10;
      }
      return nameMatch;
    }).toList();

    if (_selectedSort != null) {
      products.sort((a, b) {
        switch (_selectedSort!) {
          case ProductSort.aToZ:
            return a.name.compareTo(b.name);
          case ProductSort.zToA:
            return b.name.compareTo(a.name);
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
    final isDark = theme.brightness == Brightness.dark;

    final value = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 12,
            left: 24,
            right: 24,
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter & Sort",
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: theme.hintColor),
                  )
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, "Filter By Status"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildChoiceChip(context, "All Products", ProductFilter.all,
                      _selectedFilter),
                  _buildChoiceChip(context, "Low Stock", ProductFilter.lowStock,
                      _selectedFilter),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, "Sort By"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSortChip(context, "Name (A-Z)", ProductSort.aToZ),
                  _buildSortChip(context, "Name (Z-A)", ProductSort.zToA),
                  _buildSortChip(
                      context, "Price: High-Low", ProductSort.priceHighToLow),
                  _buildSortChip(
                      context, "Price: Low-High", ProductSort.priceLowToHigh),
                ],
              ),
              const SizedBox(height: 40),
              if (_selectedSort != null || _selectedFilter != ProductFilter.all)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, MenuAction.clearSort),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PremiumTheme.secondaryColor,
                      side:
                          const BorderSide(color: PremiumTheme.secondaryColor),
                    ),
                    child: const Text("Reset All Filters"),
                  ),
                ),
              const SizedBox(height: 24),
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

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.brightness == Brightness.dark
            ? PremiumTheme.darkTextSecondary
            : PremiumTheme.lightTextSecondary,
      ),
    );
  }

  Widget _buildChoiceChip(BuildContext context, String label, dynamic value,
      dynamic selectedValue) {
    final isSelected = value == selectedValue;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) Navigator.pop(context, value);
      },
      selectedColor: PremiumTheme.primaryColor,
      backgroundColor: theme.cardTheme.color,
      labelStyle: GoogleFonts.inter(
        color: isSelected
            ? Colors.white
            : (theme.brightness == Brightness.dark
                ? Colors.white70
                : PremiumTheme.lightTextPrimary),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isSelected ? PremiumTheme.primaryColor : theme.dividerColor),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildSortChip(BuildContext context, String label, ProductSort value) {
    final isSelected = _selectedSort == value;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) Navigator.pop(context, value);
      },
      selectedColor: PremiumTheme.primaryColor,
      backgroundColor: theme.cardTheme.color,
      labelStyle: GoogleFonts.inter(
        color: isSelected
            ? Colors.white
            : (theme.brightness == Brightness.dark
                ? Colors.white70
                : PremiumTheme.lightTextPrimary),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isSelected ? PremiumTheme.primaryColor : theme.dividerColor),
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CommonSearchBar(
            controller: searchController,
            hintText: "Search your inventory...",
            onFilterTap: () => _showFilterMenu(context),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: PremiumTheme.primaryColor));
            }

            final products = _getFilteredProducts();

            if (products.isEmpty) {
              return _buildEmptyState(theme);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isLowStock = product.quantity <= 10;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Hero(
                    tag: 'product_card_${product.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.to(() => const EditProduct(),
                            arguments: product),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.dividerColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  height: 84,
                                  width: 84,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? PremiumTheme.darkBg
                                        : PremiumTheme.lightBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: product.image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                                Icons.broken_image_outlined,
                                                color: theme.dividerColor),
                                          ),
                                        )
                                      : Icon(Icons.inventory_2_rounded,
                                          color: PremiumTheme.primaryColor
                                              .withOpacity(0.5),
                                          size: 32),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            "₹${product.price.toStringAsFixed(0)}",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: PremiumTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: theme.dividerColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Qty: ${product.quantity}",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? PremiumTheme
                                              .darkTextSecondary
                                              : PremiumTheme
                                              .lightTextSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLowStock
                                              ? PremiumTheme.secondaryColor
                                                  .withOpacity(0.1)
                                              : const Color(0xFF10B981)
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isLowStock ? "LOW STOCK" : "IN STOCK",
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                            color: isLowStock
                                                ? PremiumTheme.secondaryColor
                                                : const Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 16, color: theme.dividerColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 64, color: theme.dividerColor),
            ),
            const SizedBox(height: 24),
            Text(
              "No products found",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              "We couldn't find any products matching your search or filters.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            if (_selectedSort != null || _selectedFilter != ProductFilter.all)
              ElevatedButton(
                onPressed: () => setState(() {
                  _selectedSort = null;
                  _selectedFilter = ProductFilter.all;
                  searchController.clear();
                }),
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(200, 52)),
                child: const Text("Clear All Filters"),
              ),
          ],
        ),
      ),
    );
  }
}
