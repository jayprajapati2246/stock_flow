import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon part for all/search Product/searchbar.dart';
import 'package:stock_flow/Data Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data Layear/model/ProductModel/product_model.dart';

enum ProductFilter { all, lowStock }

enum ProductSort { aToZ, zToA, priceHighToLow, priceLowToHigh }

enum MenuAction { clearSort }

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
        return match && product.quantity <= 5;
      }
      return match;
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
    final value = await showMenu<dynamic>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 20, 100),
      items: const [
        PopupMenuItem(value: ProductFilter.all, child: Text("All Products")),
        PopupMenuItem(value: ProductFilter.lowStock, child: Text("Low Stock")),
        PopupMenuDivider(),
        PopupMenuItem(value: ProductSort.aToZ, child: Text("Name (A-Z)")),
        PopupMenuItem(value: ProductSort.zToA, child: Text("Name (Z-A)")),
        PopupMenuItem(
            value: ProductSort.priceHighToLow, child: Text("Price High-Low")),
        PopupMenuItem(
            value: ProductSort.priceLowToHigh, child: Text("Price Low-High")),
      ],
    );

    if (value == null) return;

    setState(() {
      if (value is ProductFilter) _selectedFilter = value;
      if (value is ProductSort) _selectedSort = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
      body: Column(
        children: [
          // 🔍 Search
         CommonSearchBar(
                controller: controller.searchController,
                hintText: "Search products...",
                height: 42,
                iconSize: 18,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                onChanged: (_) {},
                onFilterTap: () {
                  _showFilterMenu(context);
                },
              ),

          // 📦 Product List
          Expanded(
            child: Obx(() {
              final products = _filteredProducts();

              if (controller.allProducts.isEmpty) {
                return const Center(child: Text("No products found"));
              }

              if (products.isEmpty) {
                return const Center(child: Text("No matching products"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (_, index) => _buildProductCard(products[index]),
              );
            }),
          ),

          // 🗑 Remove All Button
          Obx(() => controller.allProducts.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      label:const Text(
                      "Remove All Products",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showRemoveAllConfirmation(context),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // 🧾 Product Card UI
  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 📦 Icon
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Image.network(
              product.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ℹ️ Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Stock: ${product.quantity}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // ❌ Remove Button
          ElevatedButton(
            onPressed: () {
              if (product.id != null) {
                controller.removeProduct(context, product.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
            "Remove",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

    ),
        ],
      ),
    );
  }

  void _showRemoveAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text("Remove All Products"),
        content: const Text(
          "This action cannot be undone. Are you sure?",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              controller.removeAllProducts(context);
              Get.back();
            },
            child: const Text(
              "Remove All",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
