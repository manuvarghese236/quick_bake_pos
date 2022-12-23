import 'package:flutter/material.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/stockslist.dart';

class Stocks extends StatefulWidget {
  final String token;
  const Stocks({Key? key, required this.token}) : super(key: key);
  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StocksList(token: widget.token),
    );
  }
}
