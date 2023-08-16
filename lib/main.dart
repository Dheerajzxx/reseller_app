import 'package:flutter/material.dart';
import 'package:reseller_plusgrow/login.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'login':(context) => const DealerLogin(),
    },
  ));
}