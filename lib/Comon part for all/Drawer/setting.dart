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
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : const AssetImage('assates/image/images.png') as ImageProvider,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'user.email@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(height: 20, thickness: 1),
             Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                   if (user != null)
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF1976D2),),
                      title: const Text('Name', style: TextStyle(fontWeight: FontWeight.w500),),
                      subtitle: Text(user.displayName ?? 'Not Provided'),
                    ),
                  const Divider(indent: 70,),
                  if (user != null)
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFF1976D2),),
                      title: const Text('Email', style: TextStyle(fontWeight: FontWeight.w500),),
                      subtitle: Text(user.email ?? 'Not provided'),
                    ),
                  const Divider(indent: 70,),
                  if (user != null)
                    ListTile(
                      leading: const Icon(Icons.phone, color: Color(0xFF1976D2),),
                      title: const Text('Phone', style: TextStyle(fontWeight: FontWeight.w500),),
subtitle: Text(user.phoneNumber ?? 'Not provided'),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  authController.logout();
                },
                icon: const Icon(Icons.logout, color: Colors.white,),
                label: const Text('Logout', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}