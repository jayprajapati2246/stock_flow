import 'package:get/get.dart';
import '../Controller/auth_controller.dart';

/// A binding to initialize the [AuthController] when the app starts.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
