import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List<ProductModel> filteredProducts = [];
  ProductFilter _selectedFilter = ProductFilter.all;
  ProductSort? _selectedSort;
  StreamSubscription? _productChangesSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize and apply filters
    _filterProducts();
    // Listen for search query changes
    searchController.addListener(_filterProducts);
    // Listen for changes in the product list
    _productChangesSubscription = controller.allProducts.listen((_) {
      _filterProducts();
    });
  }

  void _filterProducts() {
    if (!mounted) return;
    final query = searchController.text.toLowerCase();
    setState(() {
      var tempProducts = controller.allProducts.where((product) {
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

      filteredProducts = tempProducts;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _productChangesSubscription?.cancel();
    super.dispose();
  }

  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<dynamic>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<ProductFilter>(
          value: ProductFilter.all,
          child: Text("All Products"),
        ),
        const PopupMenuItem<ProductFilter>(
          value: ProductFilter.lowStock,
          child: Text("Low Stock"),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.aToZ,
          child: Text("Sort by Name (A-Z)"),
        ),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.zToA,
          child: Text("Sort by Name (Z-A)"),
        ),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.priceHighToLow,
          child: Text("Sort by Price (High-Low)"),
        ),
        const PopupMenuItem<ProductSort>(
          value: ProductSort.priceLowToHigh,
          child: Text("Sort by Price (Low-High)"),
        ),
        if (_selectedSort != null) ...[
          const PopupMenuDivider(),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.clearSort,
            child: Text("Clear Sort"),
          ),
        ]
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          if (value is ProductFilter) {
            _selectedFilter = value;
          } else if (value is ProductSort) {
            _selectedSort = value;
          } else if (value is MenuAction && value == MenuAction.clearSort) {
            _selectedSort = null;
          }
          _filterProducts();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar & Filter
        Builder(builder: (context) {
          return CommonSearchBar(
            controller: searchController,
            hintText: "Search products...",
            height: 42,
            iconSize: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            onFilterTap: () {
              _showFilterMenu(context);
            },
            onChanged: (value) {
              _filterProducts();
            },
          );
        }),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (context) {
                String title;
                if (_selectedFilter == ProductFilter.lowStock) {
                  title = "Low Stock Products";
                } else {
                  title = "Total Products";
                }

                String sortDescription = "";
                if (_selectedSort != null) {
                  switch (_selectedSort!) {
                    case ProductSort.aToZ:
                      sortDescription = " (A-Z)";
                      break;
                    case ProductSort.zToA:
                      sortDescription = " (Z-A)";
                      break;
                    case ProductSort.priceHighToLow:
                      sortDescription = " (by Price High-Low)";
                      break;
                    case ProductSort.priceLowToHigh:
                      sortDescription = " (by Price Low-High)";
                      break;
                  }
                }
                return RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "$title$sortDescription: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${filteredProducts.length}"),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
        const SizedBox(height: 5),

        // Product List
        Expanded(
          child: Builder(
            builder: (context) {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Text(_selectedFilter == ProductFilter.lowStock
                      ? "No low stock products found."
                      : "No products found. Add some!"),
                );
              }

              return ListView.builder(
                itemCount: filteredProducts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  bool isLowStock = product.quantity <= 5;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: product.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:  Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.inventory_2,
                                  size: 40, color: Colors.black54),
                        ),
                        const SizedBox(width: 12),

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Stock: ${product.quantity}",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLowStock
                                      ? const Color(0xFFFFE0B2)
                                      : const Color(0xFFC8E6C9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isLowStock ? "Low Stock" : "In Stock",
                                  style: TextStyle(
                                    color: isLowStock
                                        ? Colors.orange.shade900
                                        : Colors.green.shade900,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price & Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "₹ ${product.price}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                _actionButton(
                                    Icons.edit, "  Edit  ", const Color(0xFF1976D2),
                                    () {
                                  Get.to(() => const EditProduct(),
                                      arguments: product);
                                }),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
