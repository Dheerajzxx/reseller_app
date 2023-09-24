library reseller_plusgrow.globals;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Base URL
String baseURL = 'resellers.plusgrow.org';

getCartCount(apiToken) async {
  final response =
        await http.get(Uri.https(baseURL, "/api/cart"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    });
    var resCode = response.statusCode;
    if (resCode == 200) {
      var data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cartCount', data['cart_items'].length);
      return data['cart_items'].length;
    }
    else {
      return 0;
    }
}

getNotificationCount(apiToken) async {
  final response =
        await http.get(Uri.https(baseURL, "/api/get-my-notifications"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    });
    var resCode = response.statusCode;
    if (resCode == 200) {
      var data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notificationCount', data['unread_notifications_count']);
      return data['unread_notifications_count'];
    }
    else {
      return 0;
    }
}

class AppBarItems extends StatefulWidget implements PreferredSizeWidget {
  final String title, goToRoute;
  const AppBarItems(this.title,this.goToRoute, {super.key});

  @override
  State<AppBarItems> createState() => _AppBarItemsState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarItemsState extends State<AppBarItems> {
  int cartCount = 0, notificationCount = 0 ;
  String apiToken = '';
  List<String> routes = ["login", "/"];

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    getCartCount(apiToken);
    getNotificationCount(apiToken);
    setState(() {
      cartCount = prefs.getInt("cartCount") ?? 0;
      notificationCount = prefs.getInt("notificationCount") ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:routes.contains(ModalRoute.of(context)?.settings.name) ? null : IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, widget.goToRoute),
      ),
      backgroundColor: const Color.fromRGBO(14, 29, 48, 1),
      title: widget.title != '' ? Text(widget.title) : null,
      actions: <Widget>[
        Container(
          margin : const EdgeInsets.only(top: 12),
          child: Badge.count(
            count: cartCount,
            isLabelVisible: cartCount < 1 ? false : true,
            child: IconButton(
              onPressed: () { Navigator.pushNamed(context, 'cart'); },
              icon: const Icon(Icons.shopping_cart_rounded ),
            ),
          ),
        ),
        Container(
          margin : const EdgeInsets.only(top: 12),
          child: Badge.count(
            count: notificationCount,
            isLabelVisible: notificationCount < 1 ? false : true,
            child: IconButton(
              onPressed: () { Navigator.pushNamed(context, 'notifications'); },
              icon: const Icon(Icons.notifications_active_outlined ),
            ),
          ),
        ),
        const SizedBox(width: 20.0,)
      ],
    );
  }
}

