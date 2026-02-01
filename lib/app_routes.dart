import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/bindings/sales_binding.dart';
import 'package:stock_flow/Presentation/Auth/Login.dart';
import 'package:stock_flow/Presentation/Auth/Rigeration.dart';
import 'package:stock_flow/Presentation/Screen.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
    ),
    GetPage(
      name: '/main',
      page: () => const MainScreen(),
      binding: SalesBinding(),
    ),
    GetPage(name: '/registration', page: () => const RegistrationPage()),
  ];
}
