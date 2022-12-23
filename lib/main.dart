import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:windowspos/cart/cart.dart';
import 'package:windowspos/frontend/dashboard.dart';
import 'package:windowspos/frontend/homepage.dart';
import 'package:windowspos/frontend/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<CartModel>(
        model: CartModel(),
        child: GetMaterialApp(
          title: 'POS',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Login(),
        ));
  }
}
