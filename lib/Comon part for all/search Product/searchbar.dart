import 'package:flutter/material.dart';

class CommonSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onFilterTap;
  final Function(String)? onChanged;

  // optional size controls
  final double height;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const CommonSearchBar({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onFilterTap,
    this.onChanged,

    // default sizes
    this.height = 50,
    this.iconSize = 22,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: Icon(
                    Icons.search,
                    size: iconSize,
                    color: Colors.black,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: (height - 20) / 2),
                ),
              ),
            ),
          ),

          // optional filter button
          if (onFilterTap != null) ...[
            const SizedBox(width: 12),
            Container(
              height: height,
              width: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onFilterTap,
                icon: Icon(
                  Icons.tune,
                  size: iconSize,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
