import 'package:get/get.dart';

class ProductReportController extends GetxController {
  // Observables for product details
  var productName = "Wireless Keyboard".obs;
  var productSKU = "WK-001".obs;

  // Recent activity
  var recentSaleTitle = "Sale #1035".obs;
  var recentSaleSubtitle = "Sold 5 items • Today, 11:30 PM".obs;
  var recentSaleAmount = "₹ 5,800".obs;

  // Metrics
  var monthlySales = "₹ 15,200".obs;
  var totalSoldYTD = "₹ 350 Units".obs;

  // Chart Data
  final List<ChartData> chartData = [
    ChartData('2025', 70),
    ChartData('2024', 60),
    ChartData('2023', 50),
    ChartData('2022', 40),
    ChartData('2021', 50),
    ChartData('2020', 30),
  ];
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
