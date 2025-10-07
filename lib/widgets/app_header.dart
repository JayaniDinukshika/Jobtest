import 'package:flutter/material.dart';

import '../screens/cart_screen.dart' show CartScreen;

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? titleColor;
  final List<Widget>? actions;
  final double height;

  const AppHeader({
    super.key,
    required this.title,
    this.titleColor = Colors.amber,
    this.actions,
    this.height = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CartScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}