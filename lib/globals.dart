library reseller_plusgrow.globals;
import 'package:flutter/material.dart';

// Base URL
String baseURL = 'resellers.plusgrow.org';

// Common Appbar
class AppBarItems extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBarItems(this.title, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(14, 29, 48, 1),
      title: Text(title),
      actions: <Widget>[
        IconButton(
          onPressed: () { Navigator.pushNamed(context, 'cart'); },
          icon: const Icon(Icons.shopping_cart_rounded),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_active_outlined ),
        )
      ],
    );
  }

}

