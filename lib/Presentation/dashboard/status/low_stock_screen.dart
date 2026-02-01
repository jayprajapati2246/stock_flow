import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/product_controller.dart';
import 'package:stock_flow/Data%20Layear/model/ProductModel/product_model.dart';
import 'dart:io';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    final List<ProductModel> lowStockProducts = controller.lowStockProducts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Low Stock Products",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: lowStockProducts.isEmpty
          ? const Center(
              child: Text(
                'No low stock products found.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: lowStockProducts.length,
              itemBuilder: (context, index) {
                final product = lowStockProducts[index];
                return Card(
                  margin: const EdgeInsets.all(20),
                  child: ListTile(
                    leading: product.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
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
                        : const Icon(Icons.image_not_supported, size: 50),
                    title: Text(product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      'Qty: ${product.quantity}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
