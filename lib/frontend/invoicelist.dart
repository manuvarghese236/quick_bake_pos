import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/cart/cart.dart';
import 'package:windowspos/frontend/dashboard.dart';
import 'package:windowspos/frontend/successpage.dart';
import 'package:windowspos/models/delivery_status.dart';
import 'package:windowspos/models/locationmodel.dart';
import 'package:windowspos/models/printermodel.dart';
import 'package:windowspos/models/salesmanmodel.dart';
import 'package:image/image.dart' as im;

import '../changepaymenttype.dart';

class Receipts extends StatefulWidget {
  final String userid;
  final Map<String, dynamic> usbdevice;
  final Map<String, dynamic> userdetails;
  final String token;
  const Receipts(
      {Key? key,
      required this.token,
      required this.usbdevice,
      required this.userdetails,
      required this.userid})
      : super(key: key);

  @override
  State<Receipts> createState() => _ReceiptsState();
}

class _ReceiptsState extends State<Receipts> {
  TextEditingController selecteddate = TextEditingController();
  TextEditingController SearchTermController = TextEditingController();
  TextEditingController receivedamountcontroller = TextEditingController();
  TextEditingController authorizationcodecontroller = TextEditingController();

  String lastSelectInvoiceId = "";
  // Map<String, dynamic> salesman = {};
  // Map<String, dynamic> location = {};

  bool loading = false;
  List<dynamic> invoicelist = [];
  bool error = false;
  String message = "";
  bool paymentChange = false;
  Map<String, dynamic> selectedsalesman = {};
  Map<String, dynamic> selectedlocation = {};
  Map<String, dynamic> selectedreceipttype = {};
  dynamic imagebytes;
  Uint8List? imgdatabytes;
  Uint8List? imgrowdatabytes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    Future.delayed(Duration(seconds: 0), () async {
      print("inside init state");
      final ByteData invoicedata = await rootBundle.load(
        'assets/images/logo2.png',
      );
      final Uint8List logoimgBytes = invoicedata.buffer.asUint8List();
      final dynamic logoimage = im.decodeImage(logoimgBytes);
      final ByteData invoicerowdata = await rootBundle.load(
        'assets/images/rowim.png',
      );
      final Uint8List logorowimgBytes = invoicerowdata.buffer.asUint8List();
      setState(() {
        loading = true;
        imagebytes = logoimage;
        imgdatabytes = logoimgBytes;
        imgrowdatabytes = logorowimgBytes;
        selecteddate.text =
            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      });
      print("getSalesmanQueryList");
      final dynamic userdetailsresponse =
          await API.getSalesmanQueryList("", false, widget.token);
      loadInitSetting();
      print(userdetailsresponse);
      final dynamic userdetailsid =
          await API.indexOfList(userdetailsresponse, widget.userid.toString());
      print("Selected data");
      print(userdetailsid);

      loadDataFromServer();
      SearchTermController.addListener(() {
        loadDataFromServer();
      });
    });
  }

  loadInitSetting() async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    String user_id = blueskydehneepos.getString("user_id").toString();
    String user_name = blueskydehneepos.getString("name").toString();

    String warehouse_id = blueskydehneepos.getString("warehouse_id").toString();
    String warehouse_name =
        blueskydehneepos.getString("warehouse_name").toString();
    setState(() {
      selectedsalesman = {
        "id": user_id,
        "name": user_name,
      };
      selectedlocation = {"id": warehouse_id, "name": warehouse_name};
    });
  }

  loadDataFromServer() async {
    setState(() {
      loading = true;
    });
    dynamic invoicelistresponse = await API.invoiceListAPI(
        SearchTermController.text,
        selecteddate.text,
        selectedsalesman.isEmpty ? "" : selectedsalesman["id"],
        selectedlocation.isEmpty ? "" : selectedlocation["id"],
        widget.token);
    if (invoicelistresponse["status"] == "success") {
      setState(() {
        paymentChange = false;
        invoicelist = invoicelistresponse["data"];
        selectedreceipt = null;
        for (var element in invoicelist) {
          if (element["invoice_id"].toString() == lastSelectInvoiceId) {
            selectedreceipt = element;
          }
        }
        selectedreceipttype = receipttype[0];

        loading = false;
      });
    } else {
      setState(() {
        error = true;
        message = invoicelistresponse["message"].toString();
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  Map<String, dynamic>? selectedreceipt;
  List<dynamic> receipttype = [
    {"type": "Select", "code": ""},
    {"type": "Cash", "code": "CH"},
    {"type": "Card", "code": "CA"},
    {"type": "Cash + Card", "code": "CC"},
    {"type": "Credit Sale", "code": "CR"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: API.tilecolor,
        title: Text(
          "Invoices",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            SizedBox(
              height: 9,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 7.8,
              width: MediaQuery.of(context).size.width,
              // color: Colors.yellow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Search".toUpperCase(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat'),
                                ),
                              ])),
                      Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery.of(context).size.width / 7,
                          child: TextField(
                              controller: SearchTermController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(248, 248, 253, 1),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.green,
                                      width: 1.0,
                                    ),
                                  ),
                                  hintStyle: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color.fromRGBO(181, 184, 203, 1),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  hintText: "Search here",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0)))))
                    ],
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Date".toUpperCase(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery.of(context).size.width / 8,
                          child: TextField(
                              controller: selecteddate,
                              keyboardType: TextInputType.name,
                              style: TextStyle(
                                  color: API.textcolor,
                                  fontWeight: FontWeight.w400),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: API.tilecolor,
                                          onPrimary: Colors.white,
                                          onSurface: Colors.blueAccent,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            primary: Colors.green[700],
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    loading = true;
                                    selecteddate.text =
                                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                  });
                                  final dynamic invoicelistresponse =
                                      await API.invoiceListAPI(
                                          SearchTermController.text,
                                          selecteddate.text,
                                          selectedsalesman.isEmpty
                                              ? ""
                                              : selectedsalesman["id"],
                                          selectedlocation.isEmpty
                                              ? ""
                                              : selectedlocation["id"],
                                          widget.token);
                                  if (invoicelistresponse["status"] ==
                                      "success") {
                                    setState(() {
                                      invoicelist = invoicelistresponse["data"];
                                      loading = false;
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    Get.snackbar(
                                        "Failed",
                                        invoicelistresponse["message"]
                                            .toString(),
                                        backgroundColor: Colors.white,
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        colorText: Colors.red);
                                  }
                                } else {
                                  Get.snackbar(
                                    "Failed",
                                    "Please select a date",
                                    backgroundColor: Colors.white,
                                    colorText: Colors.red,
                                    maxWidth:
                                        MediaQuery.of(context).size.width / 4,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(248, 248, 253, 1),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.green,
                                      width: 1.0,
                                    ),
                                  ),
                                  hintStyle: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color.fromRGBO(181, 184, 203, 1),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  hintText: "Date",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0)))),
                        ),
                      ]),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Salesman".toUpperCase(),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              selectedsalesman.isNotEmpty
                                  ? Container(
                                      width: MediaQuery.of(context).size.width /
                                          4.5,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          // border:
                                          color: const Color.fromRGBO(
                                              248, 248, 253, 1),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border: Border.all(
                                              color: Colors.green, width: 1.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 15.0, 20.0, 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  6,
                                              child: Text(
                                                selectedsalesman['name']
                                                    .toString()
                                                    .toString()
                                                    .toUpperCase(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: API.textcolor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 48,
                                      width: MediaQuery.of(context).size.width /
                                          4.5,
                                      child: TypeAheadField(
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            style: TextStyle(
                                                color: API.textcolor,
                                                fontWeight: FontWeight.w400),
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color.fromRGBO(
                                                    248, 248, 253, 1),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  borderSide: BorderSide(
                                                    color: API.bordercolor,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.green,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                hintStyle: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Color.fromRGBO(
                                                        181, 184, 203, 1),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        10.0, 10.0, 10.0, 10.0),
                                                // ignore: unnecessary_null_comparison
                                                hintText: 'Enter Salesman',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0))),
                                          ),
                                          suggestionsCallback: (value) async {
                                            if (value == null) {
                                              return await API
                                                  .getSalesmanQueryList(value,
                                                      false, widget.token);
                                            } else {
                                              return await API
                                                  .getSalesmanQueryList(value,
                                                      false, widget.token);
                                            }
                                          },
                                          itemBuilder: (context,
                                              SalesManSchema? itemslist) {
                                            final listdata = itemslist;
                                            return ListTile(
                                              title: Text(
                                                "${listdata!.name.toUpperCase()}",
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: API.textcolor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                              ),
                                            );
                                          },
                                          onSuggestionSelected: (SalesManSchema?
                                              itemslist) async {
                                            final data = {
                                              'id': itemslist!.id,
                                              'name': itemslist.name,
                                            };
                                            setState(() {
                                              loading = true;
                                              selectedsalesman = data;
                                            });
                                            final dynamic invoicelistresponse =
                                                await API.invoiceListAPI(
                                                    SearchTermController.text,
                                                    selecteddate.text,
                                                    selectedsalesman.isEmpty
                                                        ? ""
                                                        : selectedsalesman[
                                                            "id"],
                                                    selectedlocation.isEmpty
                                                        ? ""
                                                        : selectedlocation[
                                                            "id"],
                                                    widget.token);
                                            print(invoicelistresponse);
                                            if (invoicelistresponse["status"] ==
                                                "success") {
                                              setState(() {
                                                invoicelist =
                                                    invoicelistresponse["data"];
                                                loading = false;
                                              });
                                            } else {
                                              setState(() {
                                                loading = false;
                                              });
                                              Get.snackbar(
                                                  "Failed",
                                                  invoicelistresponse["message"]
                                                      .toString(),
                                                  backgroundColor: Colors.white,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4.5,
                                                  colorText: Colors.red);
                                            }
                                            print(selectedsalesman);
                                          }),
                                    ),
                              RawMaterialButton(
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                    selectedsalesman = {};
                                  });
                                  final dynamic invoicelistresponse =
                                      await API.invoiceListAPI(
                                          SearchTermController.text,
                                          selecteddate.text,
                                          selectedsalesman.isEmpty
                                              ? ""
                                              : selectedsalesman["id"],
                                          selectedlocation.isEmpty
                                              ? ""
                                              : selectedlocation["id"],
                                          widget.token);
                                  print(invoicelistresponse);
                                  if (invoicelistresponse["status"] ==
                                      "success") {
                                    setState(() {
                                      invoicelist = invoicelistresponse["data"];
                                      loading = false;
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    Get.snackbar(
                                        "Failed",
                                        invoicelistresponse["message"]
                                            .toString(),
                                        backgroundColor: Colors.white,
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        colorText: Colors.red);
                                  }
                                },
                                elevation: 2.0,
                                fillColor: Colors.red,
                                padding: const EdgeInsets.all(10.0),
                                shape: const CircleBorder(
                                    side: BorderSide(color: Colors.white)),
                                child: const FaIcon(
                                  FontAwesomeIcons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Location".toUpperCase(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              selectedlocation.isNotEmpty
                                  ? Container(
                                      width: MediaQuery.of(context).size.width /
                                          3.5,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          // border:
                                          color: const Color.fromRGBO(
                                              248, 248, 253, 1),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border: Border.all(
                                              color: Colors.green, width: 1.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 15.0, 20.0, 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4.2,
                                              child: Text(
                                                selectedlocation['name']
                                                    .toString()
                                                    .toString()
                                                    .toUpperCase(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: API.textcolor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 48,
                                      width: MediaQuery.of(context).size.width /
                                          3.5,
                                      child: TypeAheadField(
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            style: TextStyle(
                                                color: API.textcolor,
                                                fontWeight: FontWeight.w400),
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: const Color.fromRGBO(
                                                    248, 248, 253, 1),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  borderSide: BorderSide(
                                                    color: API.bordercolor,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.green,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                hintStyle: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Color.fromRGBO(
                                                        181, 184, 203, 1),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        10.0, 10.0, 10.0, 10.0),
                                                // ignore: unnecessary_null_comparison
                                                hintText: 'Enter Location',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0))),
                                          ),
                                          suggestionsCallback: (value) async {
                                            if (value == null) {
                                              return await API
                                                  .getLocationsQueryList(
                                                      value, widget.token);
                                            } else {
                                              return await API
                                                  .getLocationsQueryList(
                                                      value, widget.token);
                                            }
                                          },
                                          itemBuilder: (context,
                                              LocationSchema? itemslist) {
                                            final listdata = itemslist;
                                            return ListTile(
                                              title: Text(
                                                "${listdata!.name.toUpperCase()}",
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: API.textcolor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                              ),
                                            );
                                          },
                                          onSuggestionSelected: (LocationSchema?
                                              itemslist) async {
                                            final data = {
                                              'id': itemslist!.id,
                                              'name': itemslist.name,
                                            };
                                            setState(() {
                                              loading = true;
                                              selectedlocation = data;
                                            });
                                            final dynamic invoicelistresponse =
                                                await API.invoiceListAPI(
                                                    SearchTermController.text,
                                                    selecteddate.text,
                                                    selectedsalesman.isEmpty
                                                        ? ""
                                                        : selectedsalesman[
                                                            "id"],
                                                    selectedlocation.isEmpty
                                                        ? ""
                                                        : selectedlocation[
                                                            "id"],
                                                    widget.token);
                                            print(invoicelistresponse);
                                            if (invoicelistresponse["status"] ==
                                                "success") {
                                              setState(() {
                                                invoicelist =
                                                    invoicelistresponse["data"];
                                                loading = false;
                                              });
                                            } else {
                                              setState(() {
                                                loading = false;
                                              });
                                              Get.snackbar(
                                                  "Failed",
                                                  invoicelistresponse["message"]
                                                      .toString(),
                                                  backgroundColor: Colors.white,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4,
                                                  colorText: Colors.red);
                                            }
                                            print(selectedlocation);
                                          }),
                                    ),
                              RawMaterialButton(
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                    selectedlocation = {};
                                  });
                                  final dynamic invoicelistresponse =
                                      await API.invoiceListAPI(
                                          SearchTermController.text,
                                          selecteddate.text,
                                          selectedsalesman.isEmpty
                                              ? ""
                                              : selectedsalesman["id"],
                                          selectedlocation.isEmpty
                                              ? ""
                                              : selectedlocation["id"],
                                          widget.token);
                                  print(invoicelistresponse);
                                  if (invoicelistresponse["status"] ==
                                      "success") {
                                    setState(() {
                                      invoicelist = invoicelistresponse["data"];
                                      loading = false;
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    Get.snackbar(
                                        "Failed",
                                        invoicelistresponse["message"]
                                            .toString(),
                                        backgroundColor: Colors.white,
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        colorText: Colors.red);
                                  }
                                },
                                elevation: 2.0,
                                fillColor: Colors.red,
                                padding: const EdgeInsets.all(10.0),
                                shape: const CircleBorder(
                                    side: BorderSide(color: Colors.white)),
                                child: const FaIcon(
                                  FontAwesomeIcons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: API.bordercolor,
            ),
            loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: API.tilecolor,
                      strokeWidth: 1,
                    ),
                  )
                : Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: invoicelist.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.asset("assets/images/box.png"),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: invoicelist.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () {
                                        setState(() {
                                          selectedreceipt = invoicelist[index];
                                          paymentChange = false;
                                          lastSelectInvoiceId =
                                              selectedreceipt!["invoice_id"]
                                                  .toString();
                                        });
                                      },
                                      leading: Container(
                                        height: 40,
                                        width: 30,
                                        child: Center(
                                          child: Text(
                                            (index + 1).toString(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Montserrat'),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        invoicelist[index]["invoice_no"]
                                            .toUpperCase(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      subtitle: Text(
                                        invoicelist[index]["customer_name"]
                                            .toUpperCase(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      trailing: Container(
                                        // color: Colors.yellow,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                        "VAT",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "AED : ${double.parse(invoicelist[index]["vat_amount"]).toStringAsFixed(2).toUpperCase()}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                        "Total w/t VAT",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "AED : ${(double.parse(invoicelist[index]["grand_total"]) - (double.parse(invoicelist[index]["vat_amount"]))).toStringAsFixed(2).toUpperCase()}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                        "Total",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "AED : ${double.parse(invoicelist[index]["grand_total"]).toStringAsFixed(2)}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                            // Column(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.center,
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.start,
                                            //   children: [
                                            //     Row(
                                            //       children: [
                                            //         Padding(
                                            //           padding: const EdgeInsets
                                            //               .symmetric(vertical: 5),
                                            //           child: Text(
                                            //             "Grand Total",
                                            //             textAlign:
                                            //                 TextAlign.start,
                                            //             style: TextStyle(
                                            //                 color: Colors.black,
                                            //                 fontSize: 12,
                                            //                 fontWeight:
                                            //                     FontWeight.w600,
                                            //                 fontFamily:
                                            //                     'Montserrat'),
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //     Text(
                                            //       "AED : ${double.parse(invoicelist[index]["grand_total"]).toStringAsFixed(2).toUpperCase()}",
                                            //       textAlign: TextAlign.start,
                                            //       style: TextStyle(
                                            //           color: Colors.green,
                                            //           fontSize: 13,
                                            //           fontWeight: FontWeight.w600,
                                            //           fontFamily: 'Montserrat'),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      color: API.bordercolor.withOpacity(0.8),
                                    );
                                  },
                                ),
                        ),
                        VerticalDivider(
                          color: API.bordercolor,
                          width: 1,
                        ),
                        Expanded(
                            child: Container(
                                // color: Colors.yellow,
                                child: selectedreceipt == null
                                    ? Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: FaIcon(
                                                FontAwesomeIcons.cubes,
                                                color: API.tilecolor,
                                                size: 80,
                                              ),
                                            ),
                                            Text(
                                              "Please a select receipt",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      color: API.tilecolor,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                11,
                                                            // color: Colors.green,
                                                            child: Text(
                                                              "Item Code",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Text(
                                                                "Rate",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "Qty",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "Unit",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "Amount",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "Dis",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "Total w/t VAT",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "VAT",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                              Text(
                                                                "Total",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ],
                                                          ))
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ListView.builder(
                                                          itemCount:
                                                              selectedreceipt![
                                                                      "items"]
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              height: 50,
                                                              // color: Colors.red,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        11,
                                                                    // color: Colors.green,
                                                                    child: Text(
                                                                      selectedreceipt!["items"][index]["bar_code"]
                                                                              .toString() +
                                                                          " / " +
                                                                          selectedreceipt!["items"][index]["description"]
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              10,
                                                                          fontFamily:
                                                                              'Montserrat'),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      Text(
                                                                        double.parse(selectedreceipt!["items"][index]["rate"])
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        double.parse(selectedreceipt!["items"][index]["quantity"])
                                                                            .toStringAsFixed(0),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        selectedreceipt!["items"][index]["unit_name"]
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        (double.parse(selectedreceipt!["items"][index]["quantity"]) *
                                                                                double.parse(selectedreceipt!["items"][index]["rate"]))
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        (double.parse(selectedreceipt!["items"][index]["discount"]))
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        (double.parse(selectedreceipt!["items"][index]["total_amount"]) -
                                                                                double.parse(selectedreceipt!["items"][index]["tax_vat_amount"]))
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        (double.parse(selectedreceipt!["items"][index]["tax_vat_amount"]))
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                      Text(
                                                                        double.parse(selectedreceipt!["items"][index]["total_amount"])
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontFamily:
                                                                                'Montserrat'),
                                                                      ),
                                                                    ],
                                                                  )),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                    )),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        (selectedreceipt![
                                                                    "invoice_code"] ==
                                                                DeliveryStatus
                                                                    .Assigned)
                                                            ? SizedBox()
                                                            : GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    paymentChange =
                                                                        !paymentChange;
                                                                  });
                                                                  // Navigator.push(
                                                                  //   context,
                                                                  //   MaterialPageRoute(
                                                                  //     builder:
                                                                  //         (context) =>
                                                                  //             ChangePaymentType(
                                                                  //       InvoiceId:
                                                                  //           selectedreceipt!["invoice_id"]
                                                                  //               .toString(),
                                                                  //       InvoiceNumber:
                                                                  //           selectedreceipt!["invoice_no"]
                                                                  //               .toString(),
                                                                  //       TotalAmount:
                                                                  //           selectedreceipt!["grand_total"]
                                                                  //               .toString(),
                                                                  //     ),
                                                                  //   ),
                                                                  // );
                                                                },
                                                                child: Card(
                                                                  color: Colors
                                                                      .green,
                                                                  elevation: 20,
                                                                  child:
                                                                      Container(
                                                                    height: 40,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Change Payment Type",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            const PaperSize
                                                                paper =
                                                                PaperSize.mm80;
                                                            final profile =
                                                                await CapabilityProfile
                                                                    .load();
                                                            final printer =
                                                                NetworkPrinter(
                                                                    paper,
                                                                    profile);
                                                            if (widget.usbdevice
                                                                    .isNotEmpty ||
                                                                true) {
                                                              API.printInvoiceWindows(
                                                                  BluetoothPrinter(
                                                                      deviceName: widget.usbdevice[
                                                                          "devicename"],
                                                                      vendorId:
                                                                          widget.usbdevice[
                                                                              "vendorid"],
                                                                      productId:
                                                                          widget.usbdevice[
                                                                              "productid"]),
                                                                  printer,
                                                                  selectedreceipt![
                                                                      "items"],
                                                                  imagebytes,
                                                                  selectedreceipt![
                                                                      "invoice_no"],
                                                                  selectedreceipt![
                                                                      "customer_name"],
                                                                  selectedreceipt![
                                                                      "invoice_date"],
                                                                  selectedreceipt![
                                                                      "warehouse_name"],
                                                                  widget.userdetails[
                                                                      "company_name"],
                                                                  widget.userdetails[
                                                                      "billing_address"],
                                                                  widget.userdetails[
                                                                      "genral_phno"],
                                                                  selectedreceipt![
                                                                      "customer_phone"],
                                                                  selectedreceipt![
                                                                      "sales_man"],
                                                                  selectedreceipt![
                                                                      "receipt_type"],
                                                                  selectedreceipt!["received_amount"]
                                                                      .toString(),
                                                                  widget
                                                                      .userdetails[
                                                                          "trn_no"]
                                                                      .toString(),
                                                                  selectedreceipt!["total_wo_vat"]
                                                                      .toString(),
                                                                  selectedreceipt!["total_discount"]
                                                                      .toString(),
                                                                  selectedreceipt!["total_amount"]
                                                                      .toString(),
                                                                  selectedreceipt!["vat_amount"]
                                                                      .toString(),
                                                                  selectedreceipt!["grand_total"]
                                                                      .toString(),
                                                                  selectedreceipt![
                                                                      "customer_address"],
                                                                  selectedreceipt!["received_cash_amount"]
                                                                      .toString(),
                                                                  selectedreceipt![
                                                                          "received_card_amount"]
                                                                      .toString(),
                                                                  selectedreceipt![
                                                                      "invoice_created_date_time"],
                                                                  selectedreceipt![
                                                                      "id"],
                                                                  imgrowdatabytes,
                                                                  {
                                                                    "sub_total":
                                                                        selectedreceipt![
                                                                            "total_wo_vat"],
                                                                    "vat": selectedreceipt![
                                                                        "vat_amount"],
                                                                    "total_without_vat": (double.parse(selectedreceipt!["grand_total"]) -
                                                                            (double.parse(selectedreceipt![
                                                                                "vat_amount"])))
                                                                        .toStringAsFixed(
                                                                            2)
                                                                        .toUpperCase(),
                                                                    "discount":
                                                                        selectedreceipt![
                                                                            "total_discount"],
                                                                    "grand_total":
                                                                        selectedreceipt![
                                                                            "grand_total"],
                                                                    "recipt_type":
                                                                        selectedreceipt![
                                                                            "receipt_type"],
                                                                    "received_amt":
                                                                        selectedreceipt![
                                                                            "received_amount"]
                                                                  });
                                                            }
                                                            setState(() {
                                                              loading = false;
                                                            });
                                                          },
                                                          child: Card(
                                                            color: Colors.green,
                                                            elevation: 20,
                                                            child: Container(
                                                              height: 40,
                                                              child: Center(
                                                                child: Text(
                                                                  "PRINT RECEIPT",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            VerticalDivider(
                                              color: API.bordercolor,
                                              width: 1,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5.5,
                                                  // color: Colors.red,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: paymentChange
                                                          ? ChangePaymentType(
                                                              InvoiceId:
                                                                  selectedreceipt![
                                                                          "id"]
                                                                      .toString(),
                                                              InvoiceNumber:
                                                                  selectedreceipt![
                                                                          "invoice_no"]
                                                                      .toString(),
                                                              TotalAmount:
                                                                  double
                                                                      .parse(
                                                                          selectedreceipt![
                                                                                  "grand_total"]
                                                                              .toString()),
                                                              cardAmount: selectedreceipt![
                                                                      "received_card_amount"]
                                                                  .toString(),
                                                              cashAmount: selectedreceipt![
                                                                      "received_cash_amount"]
                                                                  .toString(),
                                                              AuthCode:
                                                                  selectedreceipt![
                                                                          "authorization_code"]
                                                                      .toString(),
                                                              selectedReceipt:
                                                                  selectedreceipt![
                                                                          "receipt_type"]
                                                                      .toString(),
                                                              onResult:
                                                                  (result) async {
                                                                if (result["status"]
                                                                        .toString() ==
                                                                    "success") {
                                                                  Get.snackbar(
                                                                      "Success",
                                                                      result["message"]
                                                                          .toString(),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      maxWidth:
                                                                          MediaQuery.of(context).size.width /
                                                                              4,
                                                                      colorText:
                                                                          Colors
                                                                              .green);

                                                                  setState(() {
                                                                    paymentChange =
                                                                        false;
                                                                  });
                                                                  await loadDataFromServer();
                                                                } else {
                                                                  Get.snackbar(
                                                                      "Failed",
                                                                      result["message"]
                                                                          .toString(),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      maxWidth:
                                                                          MediaQuery.of(context).size.width /
                                                                              4,
                                                                      colorText:
                                                                          Colors
                                                                              .red);
                                                                }
                                                              },
                                                              token:
                                                                  widget.token)
                                                          : Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  "Invoice Number",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                Text(
                                                                  selectedreceipt![
                                                                          "invoice_no"]
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  "Customer",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                Text(
                                                                  selectedreceipt![
                                                                          "customer_name"]
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  "Invoice Amount",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                Text(
                                                                  SimpleConvert.safeDouble(
                                                                          selectedreceipt!["grand_total"]
                                                                              .toString())
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  "Receipt Type",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                Text(
                                                                  getReceiptTypeName(
                                                                      selectedreceipt![
                                                                              "receipt_type"]
                                                                          .toString()),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  "Received Amount",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                Text(
                                                                  selectedreceipt!["received_amount"]
                                                                              .toString() ==
                                                                          ""
                                                                      ? "NA"
                                                                      : double.parse(selectedreceipt!["received_amount"]
                                                                              .toString())
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                selectedreceipt!["receipt_type"]
                                                                            .toString() ==
                                                                        "CH"
                                                                    ? SizedBox()
                                                                    : Text(
                                                                        "Authorization Code",
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                selectedreceipt!["receipt_type"]
                                                                            .toString() ==
                                                                        "CH"
                                                                    ? SizedBox()
                                                                    : Text(
                                                                        selectedreceipt!["authorization_code"]
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                              ],
                                                            )
                                                      /* : Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 2,
                                                              ),
                                                              // Text(
                                                              //   "No of items",
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 12,
                                                              //       fontWeight:
                                                              //           FontWeight.w600,
                                                              //       fontFamily:
                                                              //           'Montserrat'),
                                                              // ),
                                                              // Text(
                                                              //   "2".toString(),
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 13,
                                                              //       fontWeight:
                                                              //           FontWeight.w400,
                                                              //       fontFamily:
                                                              //           'Montserrat'),
                                                              // ),
                                                              // SizedBox(height: 10),
                                                              // Text(
                                                              //   "Total (before discount)",
                                                              //   textAlign: TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 12,
                                                              //       fontWeight: FontWeight.w600,
                                                              //       fontFamily: 'Montserrat'),
                                                              // ),
                                                              // Text(
                                                              //   model.totalPriceBefore.toString(),
                                                              //   textAlign: TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 13,
                                                              //       fontWeight: FontWeight.w400,
                                                              //       fontFamily: 'Montserrat'),
                                                              // ),
                                                              // SizedBox(height: 10),
                                                              // Text(
                                                              //   "Discount",
                                                              //   textAlign: TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 12,
                                                              //       fontWeight: FontWeight.w600,
                                                              //       fontFamily: 'Montserrat'),
                                                              // ),
                                                              // Text(
                                                              //   model.totaldiscount.toString(),
                                                              //   textAlign: TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 13,
                                                              //       fontWeight: FontWeight.w400,
                                                              //       fontFamily: 'Montserrat'),
                                                              // ),
                                                              // SizedBox(height: 3),
                                                              // Text(
                                                              //   "Sub Total",
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 12,
                                                              //       fontWeight:
                                                              //           FontWeight.w600,
                                                              //       fontFamily:
                                                              //           'Montserrat'),
                                                              // ),
                                                              // Text(
                                                              //   "12",
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 13,
                                                              //       fontWeight:
                                                              //           FontWeight.w400,
                                                              //       fontFamily:
                                                              //           'Montserrat'),
                                                              // ),
                                                              // SizedBox(height: 3),
                                                              // Text(
                                                              //   "vat",
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 12,
                                                              //       fontWeight:
                                                              //           FontWeight.w600,
                                                              //       fontFamily:
                                                              //           'Montserrat'),
                                                              // ),
                                                              // Text(
                                                              //   "14",
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: 13,
                                                              //       fontWeight:
                                                              //           FontWeight.w400,
                                                              //       fontFamily:
                                                              //           'Montserrat'),
                                                              // ),
                                                              // SizedBox(
                                                              //   height: 2,
                                                              // ),
                                                              // Divider(
                                                              //   color: API.bordercolor,
                                                              // ),
                                                              // SizedBox(
                                                              //   height: 2,
                                                              // ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 2,
                                                                        bottom:
                                                                            4),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Receipt Type"
                                                                              .toUpperCase(),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontFamily: 'Montserrat'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        6,
                                                                    height: 40,
                                                                    child:
                                                                        InputDecorator(
                                                                      decoration: InputDecoration(
                                                                          filled: true,
                                                                          fillColor: const Color.fromRGBO(248, 248, 253, 1),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: API.bordercolor,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.green,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
                                                                          contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                          // ignore: unnecessary_null_comparison
                                                                          hintText: 'Receipt Type',
                                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
                                                                      child:
                                                                          DropdownButtonHideUnderline(
                                                                        child: DropdownButton<
                                                                            dynamic>(
                                                                          isExpanded:
                                                                              true,
                                                                          dropdownColor:
                                                                              Colors.white,
                                                                          hint:
                                                                              const Text(
                                                                            'Choose Type',
                                                                            style: TextStyle(
                                                                                color: Color.fromRGBO(135, 141, 186, 1),
                                                                                fontFamily: 'Montserrat',
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14),
                                                                          ),
                                                                          value:
                                                                              selectedreceipttype,
                                                                          isDense:
                                                                              true,
                                                                          onChanged:
                                                                              (data) async {
                                                                            setState(() {
                                                                              selectedreceipttype = data;
                                                                            });
                                                                          },
                                                                          items:
                                                                              receipttype.map((value) {
                                                                            return DropdownMenuItem<dynamic>(
                                                                                value: value,
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
                                                                                  height: 20.0,
                                                                                  padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                                                                                  child: Container(
                                                                                    child: Text(
                                                                                      value['type'].toString().toUpperCase(),
                                                                                      style: TextStyle(fontFamily: 'Montserrat', color: API.textcolor, fontWeight: FontWeight.w500, fontSize: 14),
                                                                                    ),
                                                                                  ),
                                                                                ));
                                                                          }).toList(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 2,
                                                                        bottom:
                                                                            4),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Received Amount"
                                                                              .toUpperCase(),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontFamily: 'Montserrat'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        6,
                                                                    height: 40,
                                                                    // color: Colors.red,
                                                                    child:
                                                                        TextFormField(
                                                                      readOnly: selectedreceipttype["code"] ==
                                                                              ""
                                                                          ? true
                                                                          : false,
                                                                      // controller:
                                                                      //     receivedamountcontroller,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      style: TextStyle(
                                                                          color: API
                                                                              .textcolor,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      decoration: InputDecoration(
                                                                          filled: true,
                                                                          fillColor: const Color.fromRGBO(248, 248, 253, 1),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: API.bordercolor,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.green,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
                                                                          contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                          // ignore: unnecessary_null_comparison
                                                                          hintText: 'Received Amount',
                                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
                                                                      onChanged:
                                                                          (val) {
                                                                        setState(
                                                                            () {
                                                                          receivedamountcontroller.text =
                                                                              val;
                                                                        });
                                                                      },
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              selectedreceipttype[
                                                                          "code"] ==
                                                                      "CA"
                                                                  ? Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              top: 2,
                                                                              bottom: 4),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Authorization Code".toUpperCase(),
                                                                                textAlign: TextAlign.start,
                                                                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width / 6,
                                                                          height:
                                                                              40,
                                                                          // color: Colors.red,
                                                                          child:
                                                                              TextFormField(
                                                                            controller:
                                                                                authorizationcodecontroller,
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            style:
                                                                                TextStyle(color: API.textcolor, fontWeight: FontWeight.w400),
                                                                            decoration: InputDecoration(
                                                                                filled: true,
                                                                                fillColor: const Color.fromRGBO(248, 248, 253, 1),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(4.0),
                                                                                  borderSide: BorderSide(
                                                                                    color: API.bordercolor,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(4.0),
                                                                                  borderSide: const BorderSide(
                                                                                    color: Colors.green,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                ),
                                                                                hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
                                                                                contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                                // ignore: unnecessary_null_comparison
                                                                                hintText: 'Code',
                                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )
                                                                  : SizedBox(),
                                                              SizedBox(
                                                                height: 2,
                                                              ),
                                                              Divider(
                                                                color: API
                                                                    .bordercolor,
                                                              ),
                                                              SizedBox(
                                                                height: 2,
                                                              ),
                                                              Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      7,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        top: 5),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "Grand Total",
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontFamily: 'Montserrat'),
                                                                        ),
                                                                        Text(
                                                                          double.parse(selectedreceipt!["grand_total"])
                                                                              .toStringAsFixed(2),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontFamily: 'Montserrat'),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        receivedamountcontroller.text.isEmpty
                                                                            ? SizedBox()
                                                                            : Container(
                                                                                width: MediaQuery.of(context).size.width / 5.5,
                                                                                color: Colors.green,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                        child: Text(
                                                                                          "Balance",
                                                                                          textAlign: TextAlign.start,
                                                                                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                        child: Text(
                                                                                          double.parse((double.parse(receivedamountcontroller.text) - double.parse(selectedreceipt!["grand_total"])).toString()).toStringAsFixed(2),
                                                                                          textAlign: TextAlign.start,
                                                                                          style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                        // Column(
                                                                        //         crossAxisAlignment: CrossAxisAlignment.start,
                                                                        //         children: [
                                                                        //           Text(
                                                                        //             "Balance",
                                                                        //             textAlign: TextAlign.start,
                                                                        //             style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                        //           ),
                                                                        //           Text(
                                                                        //             double.parse((double.parse(receivedamountcontroller.text) - double.parse(selectedreceipt!["grand_total"])).toString()).toStringAsFixed(2),
                                                                        //             textAlign: TextAlign.start,
                                                                        //             style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                        //           ),
                                                                        //         ],
                                                                        //       )
                                                                      ],
                                                                    ),
                                                                  ))
                                                            ],
                                                          ) */
                                                      ,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                // Column(
                                //   children: [
                                //     SizedBox(
                                //       height: 10,
                                //     ),
                                //     Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       children: [
                                //         Text(
                                //           "No : ${selectedreceipt!["id"]}",
                                //           textAlign: TextAlign.start,
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 18,
                                //               fontWeight: FontWeight.w600,
                                //               fontFamily: 'Montserrat'),
                                //         ),
                                //       ],
                                //     ),
                                //     Divider(
                                //       color: API.bordercolor,
                                //     ),
                                //     Row(
                                //       children: [
                                //         Padding(
                                //           padding:
                                //               const EdgeInsets.all(8.0),
                                //           child: FaIcon(
                                //             FontAwesomeIcons.businessTime,
                                //             color: Colors.green,
                                //             size: 20,
                                //           ),
                                //         ),
                                //         Text(
                                //           selectedreceipt!["customer_name"],
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 14,
                                //               fontWeight: FontWeight.w600,
                                //               fontFamily: 'Montserrat'),
                                //         ),
                                //       ],
                                //     ),
                                //     Row(
                                //       children: [
                                //         Padding(
                                //           padding:
                                //               const EdgeInsets.all(8.0),
                                //           child: FaIcon(
                                //             FontAwesomeIcons.moneyBill,
                                //             color: Colors.green,
                                //             size: 20,
                                //           ),
                                //         ),
                                //         Text(
                                //           selectedreceipt!["amount"] +
                                //               " AED",
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 14,
                                //               fontWeight: FontWeight.w600,
                                //               fontFamily: 'Montserrat'),
                                //         ),
                                //       ],
                                //     ),
                                //     Container(
                                //       height: 60,
                                //       child: ListView.builder(
                                //           itemCount:
                                //               selectedreceipt!["payment"]
                                //                   .length,
                                //           itemBuilder: (context, cindex) {
                                //             if (selectedreceipt!["payment"]
                                //                     [cindex]["selected"] ==
                                //                 0) {
                                //               return SizedBox();
                                //             } else {
                                //               return Card(
                                //                 color: Colors.green,
                                //                 elevation: 20,
                                //                 child: Container(
                                //                   height: 40,
                                //                   child: Center(
                                //                     child: Text(
                                //                       selectedreceipt![
                                //                                   "payment"]
                                //                               [
                                //                               cindex]["type"]
                                //                           .toString()
                                //                           .toUpperCase(),
                                //                       style: TextStyle(
                                //                           color:
                                //                               Colors.white,
                                //                           fontSize: 14,
                                //                           fontWeight:
                                //                               FontWeight
                                //                                   .w600,
                                //                           fontFamily:
                                //                               'Montserrat'),
                                //                     ),
                                //                   ),
                                //                 ),
                                //               );
                                //             }
                                //           }),
                                //     ),
                                //     SizedBox(
                                //       height: 10,
                                //     ),
                                //     Divider(
                                //       color: API.bordercolor,
                                //     ),
                                //     Card(
                                //       color: Colors.amber,
                                //       elevation: 20,
                                //       child: Container(
                                //         height: 40,
                                //         child: Center(
                                //           child: Text(
                                //             "PRINT RECEIPT",
                                //             style: TextStyle(
                                //                 color: Colors.white,
                                //                 fontSize: 14,
                                //                 fontWeight: FontWeight.w600,
                                //                 fontFamily: 'Montserrat'),
                                //           ),
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                                ))
                      ],
                    ),
                  ),
          ])),
    );
  }

  String getReceiptTypeName(String code) {
    String name = "";
    receipttype.forEach((element) {
      if (element["code"].toString().toLowerCase() == code.toLowerCase()) {
        name = element["type"];
      }
    });
    return name;
  }
}
