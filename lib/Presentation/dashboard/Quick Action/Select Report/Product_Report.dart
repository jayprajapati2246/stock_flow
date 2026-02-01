import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon part for all/search Product/searchbar.dart';
import 'package:stock_flow/Data Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data Layear/model/ProductModel/product_model.dart';
import 'package:stock_flow/Presentation/dashboard/Quick%20Action/Select%20Report/product_report_details.dart';

enum ProductFilter { all, lowStock }
enum ProductSort { aToZ, zToA, priceHighToLow, priceLowToHigh }
enum MenuAction { clearSort }

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

    setState(() {
      _filteredProducts = tempProducts;
    });
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Select Product report",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Builder(builder: (context) {
            return CommonSearchBar(
              controller: searchController,
              hintText: "Search products...",
              height: 42,
              iconSize: 18,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              onFilterTap: () {
                _showFilterMenu(context);
              },
              onChanged: (value) {
                _filterProducts();
              },
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(
                      text: "${_selectedFilter == ProductFilter.lowStock ? 'Low Stock' : 'Total'} Products${_selectedSort != null ? ' (Sorted)' : ''}: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${_filteredProducts.length}"),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          // ---------------- PRODUCT LIST ----------------
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      return InkWell(
                        onTap: () {
                          Get.to(() => ProductReportDetails(product: product));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // ---------------- IMAGE ----------------
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
                                        child:Image.network(
                                          product.image,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2,
                                        size: 40,
                                        color: Colors.black54,
                                      ),
                              ),

                              const SizedBox(width: 16),

                              // ---------------- DETAILS ----------------
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stock: ${product.quantity}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
