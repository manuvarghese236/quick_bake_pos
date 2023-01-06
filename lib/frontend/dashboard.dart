import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/cart/cart.dart';
import 'package:windowspos/frontend/customers.dart';
import 'package:windowspos/frontend/homepage.dart';
import 'package:windowspos/frontend/invoicelist.dart';
import 'package:windowspos/frontend/login.dart';
import 'package:windowspos/frontend/printerconfig.dart';
import 'package:windowspos/frontend/reports.dart';
import 'package:windowspos/frontend/reports/closing.dart';
import 'package:windowspos/frontend/reports/commisionreport.dart';
import 'package:windowspos/frontend/reports/invoicelistreport.dart';
import 'package:windowspos/frontend/reports/itemslist.dart';
import 'package:windowspos/frontend/reports/stocks.dart';
import 'package:windowspos/frontend/stockslist.dart';
import 'package:windowspos/main.dart';

class dashboard extends StatefulWidget {
  const dashboard({Key? key}) : super(key: key);

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  // TextEditingController ipaddresscontroller = TextEditingController();
  Map<String, dynamic> usbdevice = {};
  bool load = false;
  bool reportselected = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    Future.delayed(Duration(seconds: 0), () async {
      final dynamic data = await API.getUserDetails();
      final dynamic usbdataresponse = await API.getUSBPrinter();
      print(usbdataresponse);
      print(data);
      setState(() {
        userdetails = data;
      });
      if (usbdataresponse["status"] == "success") {
        setState(() {
          usbdevice["devicename"] = usbdataresponse["data"]["devicename"];
          usbdevice["vendorid"] = usbdataresponse["data"]["vendorid"];
          usbdevice["productid"] = usbdataresponse["data"]["productid"];
        });
      }
      setState(() {
        load = false;
      });
    });
  }

  Map<String, dynamic> userdetails = {};
  dynamic imagebytes;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CartModel>(builder: (context, child, model) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: API.tilecolor,
          title: InkWell(
            onTap: () {
              // API.printReceiveTest(BluetoothPrinter(
              //     address: '10.39.1.114',
              //     port: '9100',
              //     typePrinter: PrinterType.network));
            },
            child: Text(
              "Quick Bake".toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
          ),
          actions: [
            Center(
              child: Text(
                "( version - 1.0.2 )".toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ),
            IconButton(
                onPressed: () {
                  slideRightWidget(
                      newPage: PrinterConfig(
                          selectedprinter: usbdevice.isEmpty
                              ? "Not Available"
                              : usbdevice["devicename"]),
                      context: context);
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                )),
            SizedBox(
              width: 20,
            ),
            IconButton(
                onPressed: () {
                  pushWidgetWhileRemove(newPage: Login(), context: context);
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                )),
            SizedBox(
              width: 50,
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Container(
            //       width: MediaQuery.of(context).size.width / 6,
            //       height: 40,
            //       // color: Colors.red,
            //       child: TextFormField(
            //         controller: ipaddresscontroller,
            //         keyboardType: TextInputType.number,
            //         style: TextStyle(
            //             color: API.textcolor, fontWeight: FontWeight.w400),
            //         decoration: InputDecoration(
            //             filled: true,
            //             fillColor: const Color.fromRGBO(248, 248, 253, 1),
            //             enabledBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(4.0),
            //               borderSide: BorderSide(
            //                 color: API.bordercolor,
            //                 width: 1.0,
            //               ),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(4.0),
            //               borderSide: const BorderSide(
            //                 color: Colors.green,
            //                 width: 1.0,
            //               ),
            //             ),
            //             hintStyle: const TextStyle(
            //                 fontFamily: 'Montserrat',
            //                 color: Color.fromRGBO(181, 184, 203, 1),
            //                 fontWeight: FontWeight.w500,
            //                 fontSize: 14),
            //             contentPadding:
            //                 const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            //             // ignore: unnecessary_null_comparison
            //             hintText: 'IP Address',
            //             border: OutlineInputBorder(
            //                 borderRadius: BorderRadius.circular(4.0))),
            //       ),
            //     ),
            //     IconButton(
            //         onPressed: () async {
            //           final dynamic addresponse =
            //               await API.addIpAddress(ipaddresscontroller.text);
            //           if (addresponse["status"] == "success") {
            //             Get.snackbar("Success", "Ip Updated",
            //                 backgroundColor: Colors.green,
            //                 colorText: Colors.white);
            //           } else {
            //             Get.snackbar("Failed", "Ip Updation error",
            //                 backgroundColor: Colors.red,
            //                 colorText: Colors.white);
            //           }
            //         },
            //         icon: Icon(
            //           Icons.edit,
            //           color: Colors.green,
            //         ))
            //   ],
            // ),
          ],
        ),
        body: load
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: API.tilecolor,
                ),
              )
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // if (ipaddresscontroller.text == "") {
                            //   Get.snackbar("Failed", "Please add printer ip",
                            //       backgroundColor: Colors.white,
                            //       colorText: Colors.red);
                            // } else {
                            print("HomePage");
                            slideRightWidget(
                                newPage: HomePage(
                                  token: userdetails["token"],
                                  userdetails: userdetails,
                                  usbdevice: usbdevice,
                                ),
                                context: context);
                            // }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width / 4,
                            // color: Colors.yellow,
                            child: Card(
                              elevation: 20,
                              color: API.tilecolor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: API.tilewhite, width: 1),
                                            color: API.tilecolor,
                                            borderRadius:
                                                BorderRadius.circular(50.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.handshake,
                                            color: API.tilewhite,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "SALES / مبيعات",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: API.tilewhite,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // if (ipaddresscontroller.text == "") {
                            //   Get.snackbar("Failed", "Please add printer ip",
                            //       backgroundColor: Colors.white,
                            //       colorText: Colors.red);
                            // } else {
                            print("opening Receipts");
                            slideRightWidget(
                                newPage: Receipts(
                                  userdetails: userdetails,
                                  token: userdetails["token"],
                                  userid: userdetails["userid"],
                                  usbdevice: usbdevice,
                                ),
                                context: context);
                            // }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width / 4,
                            // color: Colors.yellow,
                            child: Card(
                              elevation: 20,
                              color: API.tilecolor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: API.tilewhite, width: 1),
                                            color: API.tilecolor,
                                            borderRadius:
                                                BorderRadius.circular(50.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.receipt,
                                            color: API.tilewhite,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Invoices / الفواتير",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: API.tilewhite,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            slideRightWidget(
                                newPage: Customers(
                                  token: userdetails["token"],
                                  usbdevice: usbdevice,
                                  userdetails: userdetails,
                                ),
                                context: context);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width / 4,
                            // color: Colors.yellow,
                            child: Card(
                              elevation: 20,
                              color: API.tilecolor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: API.tilewhite, width: 1),
                                            color: API.tilecolor,
                                            borderRadius:
                                                BorderRadius.circular(50.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.group,
                                            color: API.tilewhite,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Customers  / عملاء",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: API.tilewhite,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // slideRightWidget(
                            //     newPage: Reports(
                            //         token: userdetails["token"],
                            //         userid: userdetails["userid"],
                            //         username: userdetails["name"]),
                            //     context: context);
                            // setState(() {
                            //   reportselected = !reportselected;
                            // });
                            slideRightWidget(
                                newPage: Stocks(
                                  token: userdetails["token"],
                                ),
                                context: context);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width / 4,
                            // color: Colors.yellow,
                            child: Card(
                              elevation: 20,
                              color: API.tilecolor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: API.tilewhite, width: 1),
                                            color: API.tilecolor,
                                            borderRadius:
                                                BorderRadius.circular(50.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons
                                                .check_box_outline_blank_outlined,
                                            color: API.tilewhite,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Stocks  / مخازن",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: API.tilewhite,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    reportselected
                        ? Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  slideRightWidget(
                                      newPage: CommisionReport(
                                          token: userdetails["token"],
                                          userid: userdetails["userid"],
                                          username: userdetails["name"]),
                                      context: context);
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.width / 4,
                                  // color: Colors.yellow,
                                  child: Card(
                                    elevation: 20,
                                    color: API.tilecolor,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: API.tilewhite,
                                                      width: 1),
                                                  color: API.tilecolor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.file_present_rounded,
                                                  color: API.tilewhite,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            "Commision Reports  / تقرير العمولة",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: API.tilewhite,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  slideRightWidget(
                                      newPage: InvoiceListReport(
                                          token: userdetails["token"],
                                          userid: userdetails["userid"],
                                          username: userdetails["name"]),
                                      context: context);
                                  // setState(() {
                                  //   reportselected = !reportselected;
                                  // });
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.width / 4,
                                  // color: Colors.yellow,
                                  child: Card(
                                    elevation: 20,
                                    color: API.tilecolor,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: API.tilewhite,
                                                      width: 1),
                                                  color: API.tilecolor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.file_present_rounded,
                                                  color: API.tilewhite,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            "Invoice List  / قائمة الفاتورة",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: API.tilewhite,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  slideRightWidget(
                                      newPage: ItemsListReport(
                                          token: userdetails["token"],
                                          userid: userdetails["userid"],
                                          username: userdetails["name"]),
                                      context: context);
                                  // setState(() {
                                  //   reportselected = !reportselected;
                                  // });
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.width / 4,
                                  // color: Colors.yellow,
                                  child: Card(
                                    elevation: 20,
                                    color: API.tilecolor,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: API.tilewhite,
                                                      width: 1),
                                                  color: API.tilecolor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.file_present_rounded,
                                                  color: API.tilewhite,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            "Items Reports  / تقارير الأصناف",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: API.tilewhite,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  slideRightWidget(
                                      newPage: Closing(
                                        token: userdetails["token"],
                                        userdetails: userdetails,
                                      ),
                                      context: context);
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.width / 4,
                                  // color: Colors.yellow,
                                  child: Card(
                                    elevation: 20,
                                    color: API.tilecolor,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: API.tilewhite,
                                                      width: 1),
                                                  color: API.tilecolor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.file_present_rounded,
                                                  color: API.tilewhite,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            "Closing Reports  / التقارير الختامية",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: API.tilewhite,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : SizedBox()
                  ],
                ),
              ),
      );
    });
  }
}
