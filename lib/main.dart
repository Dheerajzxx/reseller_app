import 'package:flutter/material.dart';
import 'package:reseller_plusgrow/login.dart';
import 'package:reseller_plusgrow/orders_list.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'login':(context) => const DealerLogin(),
      'ordersList':(context) => const OrdersList(),
    },
  ));
}