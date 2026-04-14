import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Drawer/drawer.dart';
import 'package:stock_flow/Comon%20part%20for%20all/app%20bar/appbar.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';
import 'package:stock_flow/Presentation/sales/salse.dart';
import 'products/AllProduct.dart';
import 'dashboard/Dashboard.dart';
import 'reports/Report.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isDrawerOpen = false;

  final List<Widget> _pages = [
    const Dashboard(),
    const AllProduct(),
    const SalesEntryPage(),
    const Report(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Inventory",
    "Sales Entry",
    "Analytics",
  ];

  void _onPageSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: commonAppBar(title: _titles[_currentIndex]),
      drawer: CommonDrawer(onPageSelected: _onPageSelected),
      onDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _isDrawerOpen
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    indicatorColor: PremiumTheme.primaryColor.withOpacity(0.12),
                    elevation: 0,
                    height: 64,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      _buildNavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, "Home", 0),
                      _buildNavItem(Icons.inventory_2_rounded, Icons.inventory_2_outlined, "Inventory", 1),
                      _buildNavItem(Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, "Sales", 2),
                      _buildNavItem(Icons.analytics_rounded, Icons.analytics_outlined, "Reports", 3),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  NavigationDestination _buildNavItem(IconData selectedIcon, IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return NavigationDestination(
      icon: Icon(icon, color: PremiumTheme.lightTextSecondary),
      selectedIcon: Icon(selectedIcon, color: PremiumTheme.primaryColor),
      label: label,
    );
  }
}
