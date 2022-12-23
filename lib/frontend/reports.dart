import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/stockslist.dart';
import 'package:windowspos/models/customermodel.dart';
import 'dart:typed_data';

import 'package:windowspos/models/salesmanmodel.dart';

class Reports extends StatefulWidget {
  final String token;
  final String userid;
  final String username;
  const Reports(
      {Key? key,
      required this.token,
      required this.userid,
      required this.username})
      : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTime? startdatecontroller;
  DateTime? enddatecontroller;
  bool load = false;
  bool error = false;
  bool taxable = true;
  String message = "";
  String selectedreportindex = "-1";

  Map<String, dynamic> selectedreport = {};
  Map<String, dynamic> selectedsalesman = {};
  Map<String, dynamic> selectedcustomer = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 0), () async {
      setState(() {
        load = true;
      });
      final dynamic userdetailsresponse =
          await API.getSalesmanQueryList("", true, widget.token);
      final dynamic userdetailsid =
          await API.indexOfList(userdetailsresponse, widget.userid.toString());
      final dynamic customerslistresponse =
          await API.customersListAPI(widget.token);
      if (customerslistresponse["status"] == "success") {
        setState(() {
          customerslist = customerslistresponse["data"];
          selectedsalesman = userdetailsid == -1
              ? {}
              : {
                  "id": userdetailsresponse[userdetailsid].id,
                  "name": userdetailsresponse[userdetailsid].name
                };
          startdatecontroller = DateTime.now();
          enddatecontroller = DateTime.now();
          load = false;
        });
      } else {
        setState(() {
          error = true;
          message = customerslistresponse["msg"].toString();
          load = false;
        });
      }
      print("Selected data");
      print(userdetailsid);
    });
  }

  List<dynamic> customerslist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Reports",
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
        child: load
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                  strokeWidth: 1,
                ),
              )
            : Column(
                children: [
                  Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.yellow,
                    child: Card(
                      elevation: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/images/user.png"),
                              ),
                              selectedsalesman.isNotEmpty
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
                                                      true, widget.token);
                                            } else {
                                              return await API
                                                  .getSalesmanQueryList(value,
                                                      true, widget.token);
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
                                              selectedsalesman = data;
                                            });
                                            print(selectedsalesman);
                                          }),
                                    ),
                              RawMaterialButton(
                                onPressed: () async {
                                  setState(() {
                                    load = true;
                                    selectedsalesman = {};
                                    selectedreport = {};
                                    load = false;
                                  });
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.red,
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
                                      startdatecontroller = pickedDate;
                                    });
                                  } else {
                                    setState(() {
                                      startdatecontroller = null;
                                    });
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
                                child: Container(
                                  width: MediaQuery.of(context).size.width <
                                          1200
                                      ? MediaQuery.of(context).size.width / 4
                                      : MediaQuery.of(context).size.width / 9,
                                  height: 48,
                                  child: Card(
                                    color: API.background,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.red)),
                                    elevation: 20,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.calendarDay,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          FittedBox(
                                            child: Text(
                                              startdatecontroller == null
                                                  ? "Start Date"
                                                  : startdatecontroller!.day
                                                          .toString() +
                                                      " / " +
                                                      startdatecontroller!.month
                                                          .toString() +
                                                      " / " +
                                                      startdatecontroller!.year
                                                          .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: API.textcolor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              selectedreportindex == "3"
                                  ? GestureDetector(
                                      onTap: () async {
                                        print("This is the salesman");
                                        print(selectedsalesman);
                                        if (selectedsalesman.isEmpty) {
                                          Get.snackbar("Failed",
                                              "Please select user".toString(),
                                              backgroundColor: Colors.white,
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              colorText: Colors.red);
                                        } else {
                                          if (selectedsalesman["id"] == "0") {
                                            Get.snackbar(
                                                "Failed",
                                                "Please select particular user"
                                                    .toString(),
                                                backgroundColor: Colors.white,
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                                colorText: Colors.red);
                                          } else {
                                            if (startdatecontroller != null) {
                                              setState(() {
                                                load = true;
                                              });
                                              final dynamic
                                                  closingreportresponse =
                                                  await API.closingReportAPI(
                                                      "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                      selectedsalesman["id"],
                                                      widget.token);
                                              print("This is the response");
                                              print(closingreportresponse);
                                              if (closingreportresponse[
                                                      "status"] ==
                                                  "success") {
                                                setState(() {
                                                  selectedreport["pdfurl"] =
                                                      closingreportresponse[
                                                          "pdflink"];
                                                  load = false;
                                                });
                                                print(selectedreport);
                                              } else {
                                                setState(() {
                                                  selectedreport = {};
                                                  load = false;
                                                });
                                              }
                                            } else {
                                              Get.snackbar(
                                                  "Failed",
                                                  "Please select date range"
                                                      .toString(),
                                                  backgroundColor: Colors.white,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4,
                                                  colorText: Colors.red);
                                            }
                                          }
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    1200
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    9,
                                        height: 48,
                                        child: Card(
                                          color: API.background,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.red)),
                                          elevation: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.refresh,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                                FittedBox(
                                                  child: Text(
                                                    "Load Now".toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: API.textcolor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Colors.red,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.blueAccent,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
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
                                            enddatecontroller = pickedDate;
                                          });
                                        } else {
                                          setState(() {
                                            enddatecontroller = null;
                                          });
                                          Get.snackbar(
                                            "Failed",
                                            "Please select a date",
                                            backgroundColor: Colors.white,
                                            colorText: Colors.red,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                          );
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    1200
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    9,
                                        height: 48,
                                        child: Card(
                                          color: API.background,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.red)),
                                          elevation: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.calendarWeek,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                FittedBox(
                                                  child: Text(
                                                    enddatecontroller == null
                                                        ? "End Date"
                                                        : enddatecontroller!
                                                                .day
                                                                .toString() +
                                                            " / " +
                                                            enddatecontroller!
                                                                .month
                                                                .toString() +
                                                            " / " +
                                                            enddatecontroller!
                                                                .year
                                                                .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: API.textcolor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    // color: Colors.yellow,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 8,
                          child: Card(
                            color: Colors.red,
                            elevation: 20,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedreport = {};
                                      selectedreportindex = "2";
                                    });
                                    // print("This is the salesman");
                                    // print(selectedsalesman);
                                    // if (selectedsalesman.isEmpty) {
                                    //   Get.snackbar("Failed",
                                    //       "Please select user".toString(),
                                    //       backgroundColor: Colors.white,
                                    //       maxWidth: MediaQuery.of(context)
                                    //               .size
                                    //               .width /
                                    //           4,
                                    //       colorText: Colors.red);
                                    // } else {
                                    //   if (startdatecontroller != null &&
                                    //       enddatecontroller != null) {
                                    //     setState(() {
                                    //       selectedreportindex = "2";
                                    //       load = true;
                                    //     });
                                    //     final dynamic commisionresponse =
                                    //         await API.commisionReportListAPI(
                                    //             "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                    //             "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                    //             selectedsalesman["id"],
                                    //             widget.token);
                                    //     print("This is the response");
                                    //     print(commisionresponse);
                                    //     setState(() {
                                    //       commisionresponse["data"].length == 0
                                    //           ? selectedreport = {}
                                    //           : selectedreport["pdfurl"] =
                                    //               commisionresponse["data_pdf"]
                                    //                   ["pdflink"];
                                    //       load = false;
                                    //     });
                                    //     print(selectedreport);
                                    //   } else {
                                    //     Get.snackbar(
                                    //         "Failed",
                                    //         "Please select date range"
                                    //             .toString(),
                                    //         backgroundColor: Colors.white,
                                    //         maxWidth: MediaQuery.of(context)
                                    //                 .size
                                    //                 .width /
                                    //             4,
                                    //         colorText: Colors.red);
                                    //   }
                                    // }
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 9,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    // color: Colors.yellow,
                                    child: Card(
                                      elevation: 20,
                                      color: selectedreportindex == "2"
                                          ? Colors.green
                                          : Colors.white,
                                      child: FittedBox(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 1),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.add_box_rounded,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(
                                                "COMMISION / العمولة",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedreport = {};
                                      selectedreportindex = "1";
                                    });
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 9,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    // color: Colors.yellow,
                                    child: Card(
                                      elevation: 20,
                                      color: selectedreportindex == "1"
                                          ? Colors.green
                                          : Colors.white,
                                      child: FittedBox(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 1),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.handshake,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(
                                                "Invoice List / قائمة الفاتورة",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedreport = {};
                                      selectedreportindex = "4";
                                    });
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 9,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    // color: Colors.yellow,
                                    child: Card(
                                      elevation: 20,
                                      color: selectedreportindex == "4"
                                          ? Colors.green
                                          : Colors.white,
                                      child: FittedBox(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 1),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.percent,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(
                                                "ITEMS / العناصر",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedreport = {};
                                      selectedreportindex = "3";
                                    });
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 9,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    // color: Colors.yellow,
                                    child: Card(
                                      elevation: 20,
                                      color: selectedreportindex == "3"
                                          ? Colors.green
                                          : Colors.white,
                                      child: FittedBox(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 1),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.class_outlined,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(
                                                "CLOSING / تقرير ختامي",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedreport = {};
                                      selectedreportindex = "5";
                                    });
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 9,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    // color: Colors.yellow,
                                    child: Card(
                                      elevation: 20,
                                      color: selectedreportindex == "5"
                                          ? Colors.green
                                          : Colors.white,
                                      child: FittedBox(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 1),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.list,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(
                                                "STOCKS / مخازن",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: load
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                      strokeWidth: 1,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        height:
                                            selectedreportindex == "5" ? 0 : 60,
                                        // color: Colors.yellow,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            selectedreportindex == "2"
                                                ? Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          print(
                                                              "This is the salesman");
                                                          print(
                                                              selectedsalesman);
                                                          if (selectedsalesman
                                                              .isEmpty) {
                                                            Get.snackbar(
                                                                "Failed",
                                                                "Please select user"
                                                                    .toString(),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                colorText:
                                                                    Colors.red);
                                                          } else {
                                                            if (startdatecontroller !=
                                                                    null &&
                                                                enddatecontroller !=
                                                                    null) {
                                                              setState(() {
                                                                selectedreportindex =
                                                                    "2";
                                                                load = true;
                                                              });
                                                              final dynamic
                                                                  commisionresponse =
                                                                  await API.commisionReportListAPI(
                                                                      "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                                      "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                                      selectedsalesman[
                                                                          "id"],
                                                                      widget
                                                                          .token);
                                                              print(
                                                                  "This is the response");
                                                              print(
                                                                  commisionresponse);
                                                              setState(() {
                                                                commisionresponse["data"]
                                                                            .length ==
                                                                        0
                                                                    ? selectedreport =
                                                                        {}
                                                                    : selectedreport[
                                                                        "pdfurl"] = commisionresponse[
                                                                            "data_pdf"]
                                                                        [
                                                                        "pdflink"];
                                                                load = false;
                                                              });
                                                              print(
                                                                  selectedreport);
                                                            } else {
                                                              Get.snackbar(
                                                                  "Failed",
                                                                  "Please select date range"
                                                                      .toString(),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4,
                                                                  colorText:
                                                                      Colors
                                                                          .red);
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  1200
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  4
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  9,
                                                          height: 48,
                                                          child: Card(
                                                            color:
                                                                API.background,
                                                            shape: RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                            elevation: 20,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .file,
                                                                    color: Colors
                                                                        .green,
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                                FittedBox(
                                                                  child: Text(
                                                                    "Commision Report"
                                                                        .toString(),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        color: API
                                                                            .textcolor,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          print(
                                                              "This is the salesman");
                                                          print(
                                                              selectedsalesman);
                                                          if (selectedsalesman
                                                              .isEmpty) {
                                                            Get.snackbar(
                                                                "Failed",
                                                                "Please select user"
                                                                    .toString(),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                colorText:
                                                                    Colors.red);
                                                          } else {
                                                            if (startdatecontroller !=
                                                                    null &&
                                                                enddatecontroller !=
                                                                    null) {
                                                              setState(() {
                                                                selectedreportindex =
                                                                    "2";
                                                                load = true;
                                                              });
                                                              final dynamic
                                                                  commisionresponse =
                                                                  await API.detailedCommisionReportListAPI(
                                                                      "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                                      "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                                      selectedsalesman[
                                                                          "id"],
                                                                      widget
                                                                          .token);
                                                              print(
                                                                  "This is the response");
                                                              print(
                                                                  commisionresponse);
                                                              setState(() {
                                                                commisionresponse["data"]
                                                                            .length ==
                                                                        0
                                                                    ? selectedreport =
                                                                        {}
                                                                    : selectedreport[
                                                                        "pdfurl"] = commisionresponse[
                                                                            "data_pdf"]
                                                                        [
                                                                        "pdflink"];
                                                                load = false;
                                                              });
                                                              print(
                                                                  selectedreport);
                                                            } else {
                                                              Get.snackbar(
                                                                  "Failed",
                                                                  "Please select date range"
                                                                      .toString(),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4,
                                                                  colorText:
                                                                      Colors
                                                                          .red);
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  1200
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  4
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  9,
                                                          height: 48,
                                                          child: Card(
                                                            color:
                                                                API.background,
                                                            shape: RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                            elevation: 20,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .filePdf,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 20,
                                                                ),
                                                                FittedBox(
                                                                  child: Text(
                                                                    "Detailed Report"
                                                                        .toString(),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        color: API
                                                                            .textcolor,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            selectedreportindex == "1"
                                                ? Row(
                                                    children: [
                                                      selectedcustomer
                                                              .isNotEmpty
                                                          ? Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3.5,
                                                              height: 48,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      // border:
                                                                      color: const Color
                                                                              .fromRGBO(
                                                                          248,
                                                                          248,
                                                                          253,
                                                                          1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4.0),
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .green,
                                                                          width:
                                                                              1.0)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        20.0,
                                                                        15.0,
                                                                        20.0,
                                                                        15.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          4.2,
                                                                      child:
                                                                          Text(
                                                                        selectedcustomer['name']
                                                                            .toString()
                                                                            .toString()
                                                                            .toUpperCase(),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Montserrat',
                                                                            color:
                                                                                API.textcolor,
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
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3.5,
                                                              child:
                                                                  TypeAheadField(
                                                                      textFieldConfiguration:
                                                                          TextFieldConfiguration(
                                                                        style: TextStyle(
                                                                            color:
                                                                                API.textcolor,
                                                                            fontWeight: FontWeight.w400),
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
                                                                            hintText: 'Enter Customer',
                                                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
                                                                      ),
                                                                      suggestionsCallback:
                                                                          (value) async {
                                                                        if (value ==
                                                                            null) {
                                                                          return await API.getCustomerQueryList(
                                                                              value,
                                                                              true,
                                                                              widget.token);
                                                                        } else {
                                                                          return await API.getCustomerQueryList(
                                                                              value,
                                                                              true,
                                                                              widget.token);
                                                                        }
                                                                      },
                                                                      itemBuilder: (context,
                                                                          CustomerSchema?
                                                                              itemslist) {
                                                                        final listdata =
                                                                            itemslist;
                                                                        return ListTile(
                                                                          title:
                                                                              Text(
                                                                            "${listdata!.name.toUpperCase()}",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            softWrap:
                                                                                false,
                                                                            maxLines:
                                                                                1,
                                                                            style: TextStyle(
                                                                                fontFamily: 'Montserrat',
                                                                                color: API.textcolor,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14),
                                                                          ),
                                                                        );
                                                                      },
                                                                      onSuggestionSelected:
                                                                          (CustomerSchema?
                                                                              itemslist) async {
                                                                        final data =
                                                                            {
                                                                          'id':
                                                                              itemslist!.id,
                                                                          'name':
                                                                              itemslist.name,
                                                                        };
                                                                        setState(
                                                                            () {
                                                                          selectedcustomer =
                                                                              data;
                                                                        });
                                                                        print(
                                                                            selectedcustomer);
                                                                      }),
                                                            ),
                                                      RawMaterialButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            load = true;
                                                            selectedcustomer =
                                                                {};
                                                            selectedreport = {};
                                                            load = false;
                                                          });
                                                        },
                                                        elevation: 2.0,
                                                        fillColor: Colors.red,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        shape: const CircleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .white)),
                                                        child: const FaIcon(
                                                          FontAwesomeIcons
                                                              .close,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            selectedreportindex == "1"
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        "Non Taxable"
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      Switch(
                                                        onChanged: (val) {
                                                          setState(() {
                                                            selectedreport = {};
                                                            taxable = !taxable;
                                                          });
                                                        },
                                                        value: taxable,
                                                        activeColor:
                                                            Colors.green,
                                                        activeTrackColor:
                                                            Colors.green,
                                                        inactiveThumbColor:
                                                            Colors.redAccent,
                                                        inactiveTrackColor:
                                                            Colors.redAccent,
                                                      ),
                                                      Text(
                                                        "Taxable   ".toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color:
                                                                API.textcolor,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            selectedreportindex == "1"
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      print(
                                                          "This is the salesman");
                                                      print(selectedsalesman);
                                                      if (selectedsalesman
                                                          .isEmpty) {
                                                        Get.snackbar(
                                                            "Failed",
                                                            "Please select user"
                                                                .toString(),
                                                            backgroundColor:
                                                                Colors.white,
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                4,
                                                            colorText:
                                                                Colors.red);
                                                      } else {
                                                        if (startdatecontroller != null &&
                                                            enddatecontroller !=
                                                                null &&
                                                            selectedcustomer
                                                                .isNotEmpty) {
                                                          setState(() {
                                                            load = true;
                                                          });
                                                          final dynamic
                                                              itemsalesresponse =
                                                              await API.invoiceReportListAPI(
                                                                  "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                                  "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                                  selectedsalesman[
                                                                      "id"],
                                                                  selectedcustomer[
                                                                      "id"],
                                                                  taxable ==
                                                                          true
                                                                      ? "1"
                                                                      : "2",
                                                                  widget.token);
                                                          print(
                                                              "This is the response");
                                                          print(
                                                              itemsalesresponse);
                                                          setState(() {
                                                            itemsalesresponse[
                                                                            "data"]
                                                                        .length ==
                                                                    0
                                                                ? selectedreport =
                                                                    {}
                                                                : selectedreport[
                                                                        "pdfurl"] =
                                                                    itemsalesresponse[
                                                                            "data_pdf"]
                                                                        [
                                                                        "pdflink"];
                                                            load = false;
                                                          });
                                                          print(selectedreport);
                                                        } else {
                                                          Get.snackbar(
                                                              "Failed",
                                                              "Please select date range / customer"
                                                                  .toString(),
                                                              backgroundColor:
                                                                  Colors.white,
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  4,
                                                              colorText:
                                                                  Colors.red);
                                                        }
                                                      }
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width <
                                                              1200
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              9,
                                                      height: 48,
                                                      child: Card(
                                                        color: API.background,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                        elevation: 20,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              FaIcon(
                                                                FontAwesomeIcons
                                                                    .refresh,
                                                                color: Colors
                                                                    .green,
                                                                size: 20,
                                                              ),
                                                              FittedBox(
                                                                child: Text(
                                                                  "Load Now"
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      color: API
                                                                          .textcolor,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                            selectedreportindex == "4"
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      print(
                                                          "This is the salesman");
                                                      print(selectedsalesman);
                                                      if (selectedsalesman
                                                          .isEmpty) {
                                                        Get.snackbar(
                                                            "Failed",
                                                            "Please select user"
                                                                .toString(),
                                                            backgroundColor:
                                                                Colors.white,
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                4,
                                                            colorText:
                                                                Colors.red);
                                                      } else {
                                                        if (startdatecontroller !=
                                                                null &&
                                                            enddatecontroller !=
                                                                null) {
                                                          setState(() {
                                                            load = true;
                                                          });
                                                          final dynamic
                                                              itemsalesresponse =
                                                              await API.itemSalesReportListAPI(
                                                                  "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                                  "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                                  selectedsalesman[
                                                                      "id"],
                                                                  widget.token);
                                                          print(
                                                              "This is the response");
                                                          print(
                                                              itemsalesresponse);
                                                          setState(() {
                                                            itemsalesresponse[
                                                                            "data"]
                                                                        .length ==
                                                                    0
                                                                ? selectedreport =
                                                                    {}
                                                                : selectedreport[
                                                                        "pdfurl"] =
                                                                    itemsalesresponse[
                                                                            "data_pdf"]
                                                                        [
                                                                        "pdflink"];
                                                            load = false;
                                                          });
                                                          print(selectedreport);
                                                        } else {
                                                          Get.snackbar(
                                                              "Failed",
                                                              "Please select date range"
                                                                  .toString(),
                                                              backgroundColor:
                                                                  Colors.white,
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  4,
                                                              colorText:
                                                                  Colors.red);
                                                        }
                                                      }
                                                      // print(
                                                      //     "This is the salesman");
                                                      // print(selectedsalesman);
                                                      // if (selectedsalesman
                                                      //     .isEmpty) {
                                                      //   Get.snackbar(
                                                      //       "Failed",
                                                      //       "Please select user"
                                                      //           .toString(),
                                                      //       backgroundColor:
                                                      //           Colors.white,
                                                      //       maxWidth: MediaQuery.of(
                                                      //                   context)
                                                      //               .size
                                                      //               .width /
                                                      //           4,
                                                      //       colorText:
                                                      //           Colors.red);
                                                      // } else {
                                                      //   if (startdatecontroller != null &&
                                                      //       enddatecontroller !=
                                                      //           null &&
                                                      //       selectedcustomer
                                                      //           .isNotEmpty) {
                                                      //     setState(() {
                                                      //       load = true;
                                                      //     });
                                                      //     final dynamic
                                                      //         itemsalesresponse =
                                                      //         await API.invoiceReportListAPI(
                                                      //             "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                      //             "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                      //             selectedsalesman[
                                                      //                 "id"],
                                                      //             selectedcustomer[
                                                      //                 "id"],
                                                      //             taxable ==
                                                      //                     true
                                                      //                 ? "1"
                                                      //                 : "2",
                                                      //             widget.token);
                                                      //     print(
                                                      //         "This is the response");
                                                      //     print(
                                                      //         itemsalesresponse);
                                                      //     setState(() {
                                                      //       itemsalesresponse[
                                                      //                       "data"]
                                                      //                   .length ==
                                                      //               0
                                                      //           ? selectedreport =
                                                      //               {}
                                                      //           : selectedreport[
                                                      //                   "pdfurl"] =
                                                      //               itemsalesresponse[
                                                      //                       "data_pdf"]
                                                      //                   [
                                                      //                   "pdflink"];
                                                      //       load = false;
                                                      //     });
                                                      //     print(selectedreport);
                                                      //   } else {
                                                      //     Get.snackbar(
                                                      //         "Failed",
                                                      //         "Please select date range / customer"
                                                      //             .toString(),
                                                      //         backgroundColor:
                                                      //             Colors.white,
                                                      //         maxWidth: MediaQuery.of(
                                                      //                     context)
                                                      //                 .size
                                                      //                 .width /
                                                      //             4,
                                                      //         colorText:
                                                      //             Colors.red);
                                                      //   }
                                                      // }
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width <
                                                              1200
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              9,
                                                      height: 48,
                                                      child: Card(
                                                        color: API.background,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                        elevation: 20,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              FaIcon(
                                                                FontAwesomeIcons
                                                                    .refresh,
                                                                color: Colors
                                                                    .green,
                                                                size: 20,
                                                              ),
                                                              FittedBox(
                                                                child: Text(
                                                                  "Load Now"
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      color: API
                                                                          .textcolor,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Expanded(
                                        child: selectedreportindex == "5"
                                            ? StocksList(token: widget.token)
                                            : Container(
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10,
                                                        horizontal: 10),
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: selectedreport
                                                              .isEmpty
                                                          ? Center(
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      3,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      4,
                                                                  child: Lottie
                                                                      .asset(
                                                                          "assets/images/report.json")),
                                                            )
                                                          : SfPdfViewerTheme(
                                                              data:
                                                                  SfPdfViewerThemeData(
                                                                backgroundColor:
                                                                    API.background,
                                                              ),
                                                              child: SfPdfViewer
                                                                  .network(
                                                                API.imgurl +
                                                                    selectedreport[
                                                                        "pdfurl"],
                                                                initialZoomLevel:
                                                                    1.5,
                                                              )),
                                                    )),
                                              ),
                                      ),
                                    ],
                                  ))
                      ],
                    ),
                  ))
                ],
              ),
      ),
    );
  }
}
