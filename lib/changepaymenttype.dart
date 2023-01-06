import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:windowspos/cart/cart.dart';
import 'api/api.dart';
import 'package:http/http.dart';

class ChangePaymentType extends StatefulWidget {
  final String InvoiceId;
  final String InvoiceNumber;
  final String token;
  final double TotalAmount;
  final String selectedReceipt;
  final String cashAmount;
  final String cardAmount;
  final String AuthCode;
  final Function onResult;
  const ChangePaymentType({
    super.key,
    required this.InvoiceId,
    required this.InvoiceNumber,
    required this.selectedReceipt,
    required this.TotalAmount,
    required this.onResult(msg),
    required this.token,
    required this.cashAmount,
    required this.cardAmount,
    required this.AuthCode,
  });

  @override
  State<ChangePaymentType> createState() => _ChangePaymentTypeState();
}

class _ChangePaymentTypeState extends State<ChangePaymentType> {
  TextEditingController cashController = TextEditingController();
  TextEditingController cardController = TextEditingController();
  TextEditingController authController = TextEditingController();
  bool cardVisible = false;
  bool cashVisible = false;
  double totalAmount = 0;
  bool Loading = false;
  List<dynamic> receipttype = [
    {"type": "Select", "code": ""},
    {"type": "Cash", "code": "CH"},
    {"type": "Card", "code": "CA"},
    {"type": "Cash + Card", "code": "CC"},
    {"type": "Credit Sale", "code": "CR"},
  ];
  var selectedreceipttype = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      selectedreceipttype = receipttype[0];
      receipttype.forEach((element) {
        if (element["code"].toString() == widget.selectedReceipt) {
          selectedreceipttype = element;
        }
      });
      if (selectedreceipttype["code"].toString() == "CH") {
        cashVisible = true;
      }
      if (selectedreceipttype["code"].toString() == "CA") {
        cardVisible = true;
      }
      if (selectedreceipttype["code"].toString() == "CC") {
        cardVisible = true;
        cashVisible = true;
      }
      cardController.text =
          SimpleConvert.safeDouble(widget.cardAmount).toStringAsFixed(3);
      cashController.text =
          SimpleConvert.safeDouble(widget.cashAmount).toStringAsFixed(3);
      if (cardVisible) {
        authController.text = widget.AuthCode;
      } else {
        authController.text = "";
      }
    });
  }

  String? numberValidator(String? value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Center(
                child: Text(
                  "Change Payment Terms",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Invoice No",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: API.textcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  Text(
                    widget.InvoiceNumber,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: API.textcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  )
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Invoice Amount",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: API.textcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  Text(
                    widget.TotalAmount.toStringAsFixed(2),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: API.textcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  )
                ],
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<dynamic>(
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    'Choose Type',
                    style: TextStyle(
                        color: Color.fromRGBO(135, 141, 186, 1),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  isDense: true,
                  value:
                      selectedreceipttype.isEmpty ? null : selectedreceipttype,
                  onChanged: (data) async {
                    setState(() {
                      selectedreceipttype = data;
                      cardVisible = false;
                      cashVisible = false;
                      cashController.text = "0.00";
                      cardController.text = "0.00";
                      authController.text = "";
                      if (data["code"].toString() == "CH") {
                        cashVisible = true;
                      }
                      if (data["code"].toString() == "CA") {
                        cardVisible = true;
                      }
                      if (data["code"].toString() == "CC") {
                        cardVisible = true;
                        cashVisible = true;
                      }
                    });
                  },
                  items: receipttype.map((value) {
                    return DropdownMenuItem<dynamic>(
                        value: value,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0)),
                          height: 20.0,
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                          child: Container(
                            child: Text(
                              value['type'].toString().toUpperCase(),
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: API.textcolor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                        ));
                  }).toList(),
                ),
              ),
              const Divider(),
              cashVisible
                  ? TextFormField(
                      controller: cashController,
                      textAlign: TextAlign.right,
                      validator: (value) => numberValidator(value),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "Cash Amount", labelText: "Cash Amount"),
                    )
                  : const SizedBox(),
              cardVisible
                  ? TextFormField(
                      controller: cardController,
                      textAlign: TextAlign.right,
                      validator: (value) => numberValidator(value),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "Card Amount", labelText: "Card Amount"),
                    )
                  : SizedBox(),
              cardVisible
                  ? TextFormField(
                      controller: authController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          hintText: "Authorization code",
                          labelText: "Authorization code"),
                    )
                  : SizedBox(),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (validateForm()) {
                      setState(() {
                        Loading = true;
                      });
                      String url = API.baseurl + "Apisales/Savepaymentterm";
                      totalAmount = SimpleConvert.safeDouble(
                              cashController.text.toString()) +
                          SimpleConvert.safeDouble(
                              cardController.text.toString());
                      var data = {
                        "invoice_id": widget.InvoiceId,
                        "received_amount": totalAmount,
                        "receipt_type": selectedreceipttype["code"].toString(),
                        "received_cash_amount": cashController.text.toString(),
                        "received_card_amount": cardController.text.toString(),
                        "authorization_code":
                            authController.text.trim().toString()
                      };
//                          print(token);
                      print(url);
                      print(data);
                      final response = await post(Uri.parse(url),
                          headers: {"token": widget.token},
                          body: json.encode(data));
                      setState(() {
                        Loading = true;
                      });
                      if (response.statusCode == 200) {
                        print(response.body);
                        dynamic loginresponse = jsonDecode(response.body);
                        print(loginresponse);
                        return widget.onResult(loginresponse);
                      } else {
                        String msg = response.reasonPhrase.toString();
                        return widget
                            .onResult({"success": "error", "message": msg});
                      }
                    } else {
                      return widget.onResult(
                          {"success": "error", "message": "Amount Mismatch"});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Update Payment"),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  bool validateForm() {
    double receivedAmount = 0;
    double cashAmount =
        (double.tryParse(cashController.text.toString()) == null)
            ? 0
            : double.parse(cashController.text.toString());
    double cardAmount =
        (double.tryParse(cardController.text.toString()) == null)
            ? 0
            : double.parse(cardController.text.toString());
    if (cashVisible || cardVisible) {
      if (cashVisible) {
        receivedAmount += cashAmount;
      }
      if (cardVisible) {
        receivedAmount += cardAmount;
      }
      if (widget.TotalAmount == receivedAmount) {
        return true;
      } else {
        return false;
      }
    } else {
      cashController.text = "0.00";
      cardController.text = "0.00";
      return true;
    }
  }
}
