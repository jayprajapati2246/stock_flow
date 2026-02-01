import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (user != null)
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? 'User Name'),
              accountEmail: Text(user.email ?? 'user.email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : const AssetImage('assates/image/images.png') as ImageProvider,
              ),
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(user.displayName ?? 'Not Provided'),
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user.email ?? 'Not provided'),
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(user.phoneNumber ?? 'Not provided'),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}
