import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/report_controller.dart';

class Report extends StatelessWidget {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.put(ReportController());

    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Inventory Reports",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildReportItem(
                icon: Icons.bar_chart,
                iconColor: Colors.teal,
                bgColor: const Color(0xFFE0F2F1),
                title: "Sales Report",
                subtitle: "View daily, weekly & monthly sales stats.",
                onTap: controller.goToSalesReport,
              ),
              _buildReportItem(
                icon: Icons.assignment_outlined,
                iconColor: Colors.blue,
                bgColor: const Color(0xFFE3F2FD),
                title: "Stock Report",
                subtitle: "Overview of current stock levels.",
                onTap: controller.goToStockReport,
              ),

              _buildReportItem(
                icon: Icons.currency_rupee,
                iconColor: Colors.deepPurple,
                bgColor: const Color(0xFFEDE7F6),
                title: "Profit & Loss Report",
                subtitle: "Calculate revenue, cost, and profits.",
                onTap: controller.goToProfitLossReport,
              ),

              _buildReportItem(
                icon: Icons.inventory_2_outlined,
                iconColor: Colors.green,
                bgColor: const Color(0xFFE8F5E9),
                title: "Stock Valuation",
                subtitle: "Calculate the total value of your stock.",
                onTap: controller.goToStockValuation,
              ),
              _buildReportItem(
                icon: Icons.local_shipping_outlined,
                iconColor: Colors.blueGrey,
                bgColor: const Color(0xFFECEFF1),
                title: "Supplier Report",
                subtitle: "Supplier wise purchase and payments.",
                onTap: controller.goToSupplierReport,
              ),
              // _buildReportItem(
              //   icon: Icons.person_pin,
              //   iconColor: Colors.deepPurple,
              //   bgColor: const Color(0xFFEDE7F6),
              //   title: "User Report",
              //   subtitle: "Show User Detail and Manage it.",
              //   onTap: controller.goToUser_Report,
              // ),

            ],
          ),
        ),
      );
  }

  Widget _buildReportItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}



