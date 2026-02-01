import 'package:flutter/material.dart';

AppBar commonAppBar({required String title, String? subTitle}) {
  return AppBar(
    backgroundColor: const Color(0xFF1976D2),
    elevation: 0,
    leading: Builder(
      builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu,fontWeight: FontWeight.bold,color: Colors.white,),
        );
      },
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (subTitle != null)
          Text(
            subTitle,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
      ],
    ),
    // actions: [
    //   Container(
    //     margin: EdgeInsets.only(left: 10),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(100),
    //       border: Border.all(
    //         color: Colors.black,
    //         width: 1,
    //       ),
    //     ),
    //       child: CircleAvatar(
    //         radius: 25,
    //         backgroundImage: AssetImage("assates/image/images.png"),
    //       ),
    //   ),
    // ],
  );
}
