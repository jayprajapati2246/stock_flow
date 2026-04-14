import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';

AppBar commonAppBar({required String title, String? subTitle}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    leading: Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? PremiumTheme.darkBorder : PremiumTheme.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.menu_rounded, 
              size: 20, 
              color: isDark ? Colors.white : PremiumTheme.lightTextPrimary
            ),
          ),
        );
      },
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (subTitle != null)
          Text(
            subTitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: PremiumTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    ),
    actions: [
      Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? PremiumTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? PremiumTheme.darkBorder : PremiumTheme.lightBorder,
                ),
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded, 
                  size: 22, 
                  color: isDark ? Colors.white : PremiumTheme.lightTextPrimary
                ),
              ),
            ),
          );
        }
      ),
    ],
  );
}
