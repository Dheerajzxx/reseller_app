import 'package:flutter/material.dart';
import 'package:reseller_plusgrow/login.dart';
import 'package:reseller_plusgrow/common/cart.dart';
import 'package:reseller_plusgrow/order/orders_list.dart';
import 'package:reseller_plusgrow/order/quick_order.dart';
import 'package:reseller_plusgrow/order/last_five_purchase.dart';
import 'package:reseller_plusgrow/order/your_top_ten.dart';
import 'package:reseller_plusgrow/ticket/ask.dart';
import 'package:reseller_plusgrow/ticket/faqs.dart';
import 'package:reseller_plusgrow/ticket/create.dart';
import 'package:reseller_plusgrow/ticket/history.dart';
import 'package:reseller_plusgrow/common/notification.dart';

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
      'askQues':(context) => const Ask(),
      'faqs':(context) => const Faqs(),
      'addTicket':(context) => const AddTicket(),
      'ticketsList':(context) => const TicketsHistory(),
      'notifications':(context) => const Notifications(),

    },
  ));
}