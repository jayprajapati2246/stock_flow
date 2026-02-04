import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:stock_flow/Comon%20part%20for%20all/Drawer/drawer.dart';
import 'package:stock_flow/Comon%20part%20for%20all/app%20bar/appbar.dart';
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
    "All Product",
    "Sales Entry",
    "Report",
  ];

  void _onPageSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    double screenHeight = mq.size.height;

    return Scaffold(
      // The single AppBar for the whole app
      appBar: commonAppBar(title: _titles[_currentIndex]),
      drawer: CommonDrawer(onPageSelected: _onPageSelected),
      onDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      body: _pages[_currentIndex],
      bottomNavigationBar: _isDrawerOpen
          ? const SizedBox.shrink()
          : CurvedNavigationBar(
              index: _currentIndex,
              height: screenHeight * 0.080,
              items: const [
                Icon(Icons.home, size: 30),
                Icon(Icons.card_travel, size: 30),
                Icon(Icons.point_of_sale, size: 30),
                Icon(Icons.bar_chart, size: 30),
              ],
              color: Colors.blueAccent,
              buttonBackgroundColor: Colors.black26,
              backgroundColor: Colors.transparent,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 600),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
    );
  }
}
