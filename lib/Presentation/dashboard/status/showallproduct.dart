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

class ShowAllProduct extends StatefulWidget {
  const ShowAllProduct({super.key});

  @override
  State<ShowAllProduct> createState() => _ShowAllProductState();
}

class _ShowAllProductState extends State<ShowAllProduct> {
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
      final nameMatches = product.name.toLowerCase().contains(query);
      if (_selectedFilter == ProductFilter.lowStock) {
        return nameMatches && product.quantity <= 10;
      }
      return nameMatches;
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
              Text(
                "Sort & Filter",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Filter By"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _buildChoiceChip(context, "All Products", ProductFilter.all,
                      _selectedFilter),
                  _buildChoiceChip(context, "Low Stock", ProductFilter.lowStock,
                      _selectedFilter),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Sort By"),
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
              const SizedBox(height: 32),
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
                    child: const Text("Reset All"),
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

  Widget _buildChoiceChip(BuildContext context, String label, dynamic value,
      dynamic selectedValue) {
    final isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) Navigator.pop(context, value);
      },
      selectedColor: PremiumTheme.primaryColor,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : null,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
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
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : null,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
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
              color: isDark ? Colors.white : PremiumTheme.lightTextPrimary,
              size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Product Catalog",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text("No products found",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: products.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isLowStock = product.quantity <= 10;

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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.to(() => const EditProduct(),
                            arguments: product),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? PremiumTheme.darkBg
                                      : PremiumTheme.lightBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: product.image.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
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
                                        size: 28),
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 6),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isLowStock
                                                ? PremiumTheme.secondaryColor
                                                    .withOpacity(0.1)
                                                : const Color(0xFF10B981)
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "QTY: ${product.quantity}",
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: isLowStock
                                                  ? PremiumTheme.secondaryColor
                                                  : const Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ],
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
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
