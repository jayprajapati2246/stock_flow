import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Drawer/setting.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';

class CommonDrawer extends StatefulWidget {
  final Function(int) onPageSelected;

  const CommonDrawer({super.key, required this.onPageSelected});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: (user?.photoURL != null)
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage("assates/image/images.png")
                as ImageProvider,
              ),
              accountName: Text(
                user?.displayName ?? "Stock Flow",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: null,
            );
          }),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text("Dashboard"),
            onTap: () {
              widget.onPageSelected(0);
              Get.back();
            },
          ),

          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.blue),
            title: const Text("All Product"),
            onTap: () {
              widget.onPageSelected(1);
              Get.back();
            },
          ),

          ListTile(
            leading: const Icon(Icons.point_of_sale, color: Colors.blue),
            title: const Text("Sales Entry"),
            onTap: () {
              widget.onPageSelected(2);
              Get.back();
            },
          ),

          Obx(() {
            if (authController.isAdmin.value) {
              return ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.blue),
                title: const Text("Report"),
                onTap: () {
                  widget.onPageSelected(3);
                  Get.back();
                },
              );
            } else {
              return Container();
            }
          }),

          const Spacer(),

          Obx(() {
            if (authController.isAdmin.value) {
              return ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text("Settings"),
                onTap: () {
                  Get.to(() => const SettingsPage());
                },
              );
            } else {
              return Container();
            }
          }),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              authController.logout();
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}