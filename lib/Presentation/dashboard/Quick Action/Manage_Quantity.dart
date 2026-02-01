import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon%20part%20for%20all/app%20bar/appbar.dart';
import 'package:stock_flow/Comon%20part%20for%20all/search%20Product/searchbar.dart';
import 'package:stock_flow/Data%20Layear/Controller/dashboard_Manage_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';

enum MenuAction { clearSort }

class ManageQuantity extends StatefulWidget {
  const ManageQuantity({super.key});

  @override
  State<ManageQuantity> createState() => _ManageQuantityState();
}

class _ManageQuantityState extends State<ManageQuantity> {
  final DashboardManageController controller =
  Get.put(DashboardManageController());
  final Map<String, TextEditingController> adjustmentControllers = {};


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
        if (controller.selectedSort.value != null) ...[
          const PopupMenuDivider(),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.clearSort,
            child: Text("Clear Sort"),
          ),
        ]
      ],
    ).then((value) {
      if (value != null) {
        if (value is ProductFilter) {
          controller.setFilter(value);
        } else if (value is ProductSort) {
          controller.setSort(value);
        } else if (value is MenuAction && value == MenuAction.clearSort) {
          controller.setSort(null);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Manage Quantity",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            return CommonSearchBar(
              controller: controller.manageQuantitySearchController,
              hintText: "Search products...",
              height: 42,
              iconSize: 18,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              onChanged: (_) {},
              onFilterTap: () {
                _showFilterMenu(context);
              },
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                String title;
                if (controller.selectedFilter.value == ProductFilter.lowStock) {
                  title = "Low Stock Products";
                } else {
                  title = "Total Products";
                }

                String sortDescription = "";
                if (controller.selectedSort.value != null) {
                  switch (controller.selectedSort.value!) {
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
                      TextSpan(
                          text: "${controller.filteredProducts.length}"),
                    ],
                  ),
                );
              }),
            ),
          ),

          // PRODUCT LIST
          Expanded(
            child: Obx(() {
              final products = controller.filteredProducts;

              if (products.isEmpty) {
                return const Center(child: Text("No products found"));
              }

              return ListView.builder(
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final product = controller.filteredProducts[index];
                    final adjustment = controller.getAdjustment(product.id!);
                    return _quantityCard(product, adjustment);
                  });
                },
              );

            }),
          ),

          // SAVE BUTTON
          Obx(() {
            return controller.productController.allProducts.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.productController.isLoading.value
                              ? null
                              : () => controller.saveChanges(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.productController.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _quantityCard(ProductModel product, int adjustment) {
    final TextEditingController textController =
        TextEditingController(text: "$adjustment");
    // textController.selection = TextSelection.fromPosition(
    //     TextPosition(offset: textController.text.length));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          /// IMAGE
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : const Icon(Icons.inventory_2),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                // Text("SKU: ${product.sku}",
                //     style:
                //     TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Text("Quantity: ${product.quantity}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          /// ADJUSTMENT
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    final intValue = int.tryParse(value) ?? 0;
                    controller.updateAdjustment(product.id!, intValue);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  TextEditingController getController(String productId, int value) {
    if (!adjustmentControllers.containsKey(productId)) {
      adjustmentControllers[productId] =
          TextEditingController(text: value.toString());
    }
    return adjustmentControllers[productId]!;
  }

}
