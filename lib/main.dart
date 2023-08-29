import 'package:flutter/material.dart';
import 'package:reseller_plusgrow/login.dart';
import 'package:reseller_plusgrow/orders_list.dart';
import 'package:reseller_plusgrow/quick_order.dart';
import 'package:reseller_plusgrow/last_five_purchase.dart';
import 'package:reseller_plusgrow/your_top_ten.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'login':(context) => const DealerLogin(),
      'ordersList':(context) => const OrdersList(),
      'quickOrder':(context) => const QuickOrder(),
      'lastFivePurchases':(context) => const LastFive(),
      'yourTopTen':(context) => const YourTopTen(),
    },
  ));
}