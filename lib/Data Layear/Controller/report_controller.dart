import 'package:get/get.dart';

import 'package:stock_flow/Presentation/reports/Report%20type/ProfitLoss_Report.dart';
import 'package:stock_flow/Presentation/reports/Report%20type/Sales_Report.dart';
import 'package:stock_flow/Presentation/reports/Report%20type/Stock_Report.dart';
import 'package:stock_flow/Presentation/reports/Report%20type/Stock_Valuation.dart';
import 'package:stock_flow/Presentation/reports/Report%20type/Supplier_Report.dart';
import 'package:stock_flow/Presentation/reports/Report%20type/user_Report.dart';

class ReportController extends GetxController {
  void goToSalesReport() {
    Get.to(() => const SalesReport());
  }

  void goToStockReport() {
    Get.to(() => const StockReport());
  }

  void goToUser_Report() {
    Get.to(() => user_report());
  }

  void goToProfitLossReport() {
    Get.to(() => const ProfitLossReport());
  }

  void goToStockValuation() {
    Get.to(() => const StockValuation());
  }

  void goToSupplierReport() {
    Get.to(() => const SupplierReport());
  }

}
