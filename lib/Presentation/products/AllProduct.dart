import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon part for all/search Product/searchbar.dart';
import 'package:stock_flow/Data Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data Layear/model/ProductModel/product_model.dart';
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
      setState(() {});
    });
  }

  List<ProductModel> _getFilteredProducts() {
    final query = searchController.text.toLowerCase();

    List<ProductModel> products = controller.allProducts.where((product) {
      final nameMatch = product.name.toLowerCase().contains(query);
      if (_selectedFilter == ProductFilter.lowStock) {
        return nameMatch && product.quantity <= 5;
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
    final value = await showMenu<dynamic>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 20, 100),
      items: [
        const PopupMenuItem(value: ProductFilter.all, child: Text("All Products")),
        const PopupMenuItem(value: ProductFilter.lowStock, child: Text("Low Stock")),
        const PopupMenuDivider(),
        const PopupMenuItem(value: ProductSort.aToZ, child: Text("Name (A-Z)")),
        const PopupMenuItem(value: ProductSort.zToA, child: Text("Name (Z-A)")),
        const PopupMenuItem(value: ProductSort.priceHighToLow, child: Text("Price High-Low")),
        const PopupMenuItem(value: ProductSort.priceLowToHigh, child: Text("Price Low-High")),
        if (_selectedSort != null) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(value: MenuAction.clearSort, child: Text("Clear Sort")),
        ],
      ],
    );

    if (value == null) return;

    setState(() {
      if (value is ProductFilter) {
        _selectedFilter = value;
      } else if (value is ProductSort) {
        _selectedSort = value;
      } else if (value == MenuAction.clearSort) {
        _selectedSort = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = _getFilteredProducts();

            if (products.isEmpty) {
              return const Center(child: Text("No products found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isLowStock = product.quantity <= 5;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🖼 Product Image
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: product.image.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                            ),
                          )
                              : const Icon(Icons.inventory_2, size: 36),
                        ),
                        const SizedBox(width: 12),

                        // 📄 Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

                              const SizedBox(height: 6),

                              // 🏷 Stock Status Badge
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLowStock
                                      ? const Color(0xFFFFE0B2)
                                      : const Color(0xFFC8E6C9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isLowStock ? "Low Stock" : "In Stock",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isLowStock
                                        ? Colors.orange.shade900
                                        : Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 💰 Price & Edit
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹ ${product.price}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            InkWell(
                              onTap: () {
                                Get.to(() => const EditProduct(), arguments: product);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 16, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
