import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/theme_controller.dart';
import 'package:stock_flow/app_routes.dart';
import 'package:stock_flow/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  Get.put(ThemeController());
  Get.put(AuthController());

  runApp(const Inventory());
}

class Inventory extends StatelessWidget {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: PremiumTheme.light,
      darkTheme: PremiumTheme.dark,
      themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const InventorySplash()),
        ...AppPages.routes,
      ],
    ));
  }
}

class InventorySplash extends StatefulWidget {
  const InventorySplash({super.key});

  @override
  State<InventorySplash> createState() => _InventorySplashState();
}

class _InventorySplashState extends State<InventorySplash> {
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();

    Timer(const Duration(seconds: 3), () {
      if (authController.currentUser.value != null) {
        Get.offAllNamed('/main');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: PremiumTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.25,
              width: size.width * 0.50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: size.width * 0.25,
                  color: PremiumTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            Text(
              "STOCK FLOW",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Premium Inventory Management",
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
