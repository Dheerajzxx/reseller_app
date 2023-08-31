import 'package:flutter/material.dart';
import 'package:reseller_plusgrow/login.dart';
import 'package:reseller_plusgrow/order/orders_list.dart';
import 'package:reseller_plusgrow/order/quick_order.dart';
import 'package:reseller_plusgrow/order/last_five_purchase.dart';
import 'package:reseller_plusgrow/order/your_top_ten.dart';
import 'package:reseller_plusgrow/cart.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      '/':(context) => const DealerLogin(),
      'login':(context) => const DealerLogin(),
      'cart':(context) => const Cart(),
      'ordersList':(context) => const OrdersList(),
      'quickOrder':(context) => const QuickOrder(),
      'lastFivePurchases':(context) => const LastFive(),
      'yourTopTen':(context) => const YourTopTen(),
    },
  ));
}