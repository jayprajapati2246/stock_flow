import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/user_controller.dart';

class user_report extends StatelessWidget {
  const user_report({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, 
            size: 20
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "User Profile",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        final user = controller.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator(color: PremiumTheme.primaryColor));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _buildProfileCard(context, user),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Account Security"),
              const SizedBox(height: 16),
              _buildSettingTile(context, Icons.lock_outline_rounded, "Change Password", "Update your security credentials", Colors.indigo),
              const SizedBox(height: 12),
              _buildSettingTile(context, Icons.shield_outlined, "Two-Factor Auth", "Enable extra protection", Colors.green),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Danger Zone"),
              const SizedBox(height: 16),
              _buildSettingTile(context, Icons.delete_outline_rounded, "Delete Account", "Permanently remove your data", PremiumTheme.secondaryColor),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PremiumTheme.primaryColor.withOpacity(0.2), width: 4),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.dividerColor,
                  backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                      ? NetworkImage(user.photoURL!)
                      : const AssetImage('assates/image/images.png') as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "${user.fname} ${user.lname}",
            style: theme.textTheme.displaySmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: PremiumTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(context, "STATUS", "Active"),
              Container(width: 1, height: 30, color: theme.dividerColor),
              _buildStat(context, "ROLE", "Administrator"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: theme.hintColor, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      ],
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

  Widget _buildSettingTile(BuildContext context, IconData icon, String title, String subtitle, Color color) {
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
          onTap: () {},
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
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
