import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/sales_controller.dart';

class SalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesController>(() => SalesController());
  }
}
