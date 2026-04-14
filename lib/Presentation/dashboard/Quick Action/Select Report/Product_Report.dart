import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/enums.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Select%20Report/product_report_details.dart';

class selectProduct extends StatefulWidget {
  const selectProduct({super.key});

  @override
  State<selectProduct> createState() => _PeportProductState();
}

class _PeportProductState extends State<selectProduct> {
  final TextEditingController searchController = TextEditingController();
  final ProductController productController = Get.find<ProductController>();

  List<ProductModel> _filteredProducts = [];
  ProductFilter _selectedFilter = ProductFilter.all;
  ProductSort? _selectedSort;

  @override
  void initState() {
    super.initState();
    _filterProducts();
    searchController.addListener(_filterProducts);
    productController.allProducts.listen((_) => _filterProducts());
  }

  void _filterProducts() {
    final query = searchController.text.toLowerCase();
    var tempProducts = productController.allProducts.where((product) {
      final nameMatches = product.name.toLowerCase().contains(query);
      if (_selectedFilter == ProductFilter.lowStock) {
        return nameMatches && product.quantity <= 5;
      }
      return nameMatches;
    }).toList();

    if (_selectedSort != null) {
      tempProducts.sort((a, b) {
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

    if (mounted) {
      setState(() {
        _filteredProducts = tempProducts;
      });
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_filterProducts);
    searchController.dispose();
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
              Text("Report Filters", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Filter Status"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _filterChip(context, "All Products", ProductFilter.all),
                  _filterChip(context, "Low Stock", ProductFilter.lowStock),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Sort Results"),
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
              if (_selectedSort != null || _selectedFilter != ProductFilter.all)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSort = null;
                        _selectedFilter = ProductFilter.all;
                      });
                      _filterProducts();
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
        color: theme.hintColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, ProductFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
          _filterProducts();
          Navigator.pop(context);
        }
      },
      selectedColor: PremiumTheme.primaryColor,
      labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
  }

  Widget _sortChip(BuildContext context, String label, ProductSort sort) {
    final isSelected = _selectedSort == sort;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedSort = sort);
          _filterProducts();
          Navigator.pop(context);
        }
      },
      selectedColor: PremiumTheme.primaryColor,
      labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
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
          "Product Reports",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CommonSearchBar(
              controller: searchController,
              hintText: "Select a product for detailed report...",
              onFilterTap: () => _showFilterMenu(context),
              onChanged: (value) => _filterProducts(),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_selectedFilter == ProductFilter.lowStock ? 'Low Stock' : 'Total'}: ${_filteredProducts.length}",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (_selectedSort != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: PremiumTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("Sorted", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PremiumTheme.primaryColor)),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          onTap: () => Get.to(() => ProductReportDetails(product: product)),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        'Stock Level: ${product.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: product.quantity <= 5 ? PremiumTheme.secondaryColor : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text("No products found", style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}
