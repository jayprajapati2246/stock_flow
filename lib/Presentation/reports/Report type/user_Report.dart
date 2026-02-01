import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/user_controller.dart';


class user_report extends StatelessWidget {
  const user_report({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "User Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        final user = controller.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- USER INFO CARD ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null || user.photoURL!.isEmpty
                            ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${user.fname} ${user.lname}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Role: ",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          // Text(
                          //   user.role.toUpperCase(),
                          //   style: const TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- ACTIONS CARD ---
              // Card(
              //   elevation: 2,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(12.0),
              //     child: Column(
              //       children: [
              //         if (user.role == 'admin')
              //           _buildActionButton(
              //             context,
              //             icon: Icons.admin_panel_settings,
              //             label: "Admin Panel",
              //             color: Colors.blue.shade700,
              //             onTap: () {
              //            //   Get.to(() => const AdminPanel());
              //             },
              //           ),
              //         _buildActionButton(
              //           context,
              //           icon: Icons.settings,
              //           label: "Settings",
              //           color: Colors.grey.shade700,
              //           onTap: () {
              //             // TODO: Navigate to Settings
              //             Get.snackbar("Settings", "Navigate to user settings");
              //           },
              //         ),
              //         const Divider(),
              //         _buildActionButton(
              //           context,
              //           icon: Icons.logout,
              //           label: "Logout",
              //           color: Colors.red.shade600,
              //           onTap: () {
              //             //controller.logout();
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
