import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Drawer/setting.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Data%20Layear/Controller/theme_controller.dart';

class CommonDrawer extends StatefulWidget {
  final Function(int) onPageSelected;

  const CommonDrawer({super.key, required this.onPageSelected});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: BoxDecoration(
                color: isDark ? PremiumTheme.darkSurface : PremiumTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: (user?.photoURL != null)
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage("assates/image/images.png") as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Stock Flow",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authController.isAdmin.value ? "Administrator" : "Staff Member",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _drawerItem(
                  icon: Icons.dashboard_rounded,
                  label: "Dashboard",
                  onTap: () {
                    widget.onPageSelected(0);
                    Get.back();
                  },
                ),
                _drawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: "All Product",
                  onTap: () {
                    widget.onPageSelected(1);
                    Get.back();
                  },
                ),
                _drawerItem(
                  icon: Icons.point_of_sale_rounded,
                  label: "Sales Entry",
                  onTap: () {
                    widget.onPageSelected(2);
                    Get.back();
                  },
                ),
                Obx(() {
                  if (authController.isAdmin.value) {
                    return _drawerItem(
                      icon: Icons.bar_chart_rounded,
                      label: "Report",
                      onTap: () {
                        widget.onPageSelected(3);
                        Get.back();
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Divider(),
                ),

                Obx(() {
                  if (authController.isAdmin.value) {
                    return _drawerItem(
                      icon: Icons.settings_rounded,
                      label: "Settings",
                      onTap: () {
                        Get.to(() => const SettingsPage());
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                _buildSettingTile(
                  context,
                  icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.orange : Colors.indigo,
                  title: "Appearance",
                  subtitle: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
                  trailing: Obx(() => Switch.adaptive(
                    value: themeController.isDarkMode.value,
                    onChanged: (_) => themeController.toggleTheme(),
                    activeColor: PremiumTheme.primaryColor,
                  )),
                  onTap: () => themeController.toggleTheme(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25),
            child: ListTile(
              onTap: () => authController.logout(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: PremiumTheme.secondaryColor.withOpacity(0.1),
              leading: const Icon(Icons.logout_rounded, color: PremiumTheme.secondaryColor),
              title: Text(
                "Logout",
                style: GoogleFonts.inter(
                  color: PremiumTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? PremiumTheme.darkTextPrimary : PremiumTheme.lightTextPrimary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
}
