import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

enum ProductFilter { all, lowStock }
enum ProductSort { aToZ, zToA, priceHighToLow, priceLowToHigh }
enum MenuAction { clearSort }

class RemoveProduct extends StatefulWidget {
  const RemoveProduct({super.key});

  @override
  State<RemoveProduct> createState() => _RemoveProductState();
}

class _RemoveProductState extends State<RemoveProduct> {
  final ProductController controller = Get.put(ProductController());
  final TextEditingController searchController = TextEditingController();
  List<ProductModel> filteredProducts = [];
  ProductFilter _selectedFilter = ProductFilter.all;
  ProductSort? _selectedSort;
  StreamSubscription? _productChangesSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for search query changes
    searchController.addListener(_filterProducts);
    // Listen for changes in the product list
    _productChangesSubscription = controller.allProducts.listen((_) {
      _filterProducts();
    });
    // Apply initial filter
    _filterProducts();
  }

  void _filterProducts() {
    if (!mounted) return; // Prevent calling setState on a disposed widget
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
    _productChangesSubscription?.cancel();
    searchController.dispose();
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Remove Product",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Builder(builder: (context) {
              return CommonSearchBar(
                controller: searchController,
                hintText: "Search products...",
                height: 42,
                iconSize: 18,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onChanged: (value) {
                  _filterProducts();
                },
                onFilterTap: () {
                  _showFilterMenu(context);
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Builder(builder: (context) {
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
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "$title$sortDescription: ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "${filteredProducts.length}"),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Obx(() {
                if (controller.allProducts.isEmpty) {
                  return const Center(child: Text("No products found"));
                }
                if (filteredProducts.isEmpty) {
                  return const Center(
                      child: Text("No products match your search"));
                }
                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductCard(product);
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return controller.allProducts.isNotEmpty
                  ? SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _showRemoveAllConfirmation(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Remove All Products",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  void _showRemoveAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove All Products"),
        content: const Text(
            "Are you sure you want to remove all products? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              controller.removeAllProducts(context);
              Navigator.pop(context);
            },
            child: const Text("Remove All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Stock: ${product.quantity}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                if (product.id != null) {
                  controller.removeProduct(context, product.id!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Remove",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
