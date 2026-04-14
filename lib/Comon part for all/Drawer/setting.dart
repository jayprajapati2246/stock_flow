import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : PremiumTheme.lightTextPrimary,
              size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Settings",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) _buildProfileHeader(context, user),
            const SizedBox(height: 40),


            const SizedBox(height: 32),
            _buildSectionHeader(context, "Account Details"),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, Icons.person_outline_rounded,
                      "Display Name", user?.displayName ?? "Not set"),
                  _buildDivider(context),
                  _buildInfoRow(context, Icons.email_outlined, "Email Address",
                      user?.email ?? "Not set"),
                  _buildDivider(context),
                  _buildInfoRow(context, Icons.phone_outlined, "Phone Number",
                      user?.phoneNumber ?? "Not set"),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Danger Zone"),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.logout_rounded,
              color: PremiumTheme.secondaryColor,
              title: "Sign Out",
              subtitle: "Exit from your account securely",
              onTap: () => _showLogoutConfirmation(context, authController),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: PremiumTheme.primaryColor.withOpacity(0.2),
                      width: 4),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.dividerColor,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : const AssetImage('assates/image/images.png')
                          as ImageProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.displayName ?? 'Stock Flow User',
            style: theme.textTheme.displaySmall?.copyWith(fontSize: 25),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: PremiumTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              user.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: theme.hintColor,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required String subtitle,
        Widget? trailing,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: theme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PremiumTheme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor,
        indent: 56);
  }

  void _showLogoutConfirmation(
      BuildContext context, AuthController controller) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("Sign Out?",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        content: const Text(
            "You will need to login again to access your inventory and sales data."),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text("Stay Logged In",
                  style: TextStyle(
                      color: theme.hintColor, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.secondaryColor,
                minimumSize: const Size(120, 48)),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}
