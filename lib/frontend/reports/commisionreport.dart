import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/models/salesmanmodel.dart';

class CommisionReport extends StatefulWidget {
  final String token;
  final String userid;
  final String username;
  const CommisionReport(
      {Key? key,
      required this.token,
      required this.userid,
      required this.username})
      : super(key: key);

  @override
  State<CommisionReport> createState() => _CommisionReportState();
}

class _CommisionReportState extends State<CommisionReport> {
  bool load = false;
  DateTime? startdatecontroller = DateTime.now();
  DateTime? enddatecontroller = DateTime.now();
  Map<String, dynamic> selectedsalesman = {};
  Map<String, dynamic> selectedreport = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: API.tilecolor,
        title: Text(
          "Commision Reports",
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
                  color: API.tilecolor,
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
                                                  6.2,
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
                                      colorText: API.tilecolor,
                                      maxWidth:
                                          MediaQuery.of(context).size.width / 4,
                                    );
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width <
                                          1200
                                      ? MediaQuery.of(context).size.width / 7
                                      : MediaQuery.of(context).size.width / 9,
                                  height: 48,
                                  child: Card(
                                    color: API.background,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: API.tilecolor)),
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
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1200
                                                          ? 12
                                                          : 15,
                                                  fontWeight: FontWeight.w400),
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
                                      colorText: API.tilecolor,
                                      maxWidth:
                                          MediaQuery.of(context).size.width / 4,
                                    );
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width <
                                          1200
                                      ? MediaQuery.of(context).size.width / 7
                                      : MediaQuery.of(context).size.width / 9,
                                  height: 48,
                                  child: Card(
                                    color: API.background,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: API.tilecolor)),
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
                                                  : enddatecontroller!.day
                                                          .toString() +
                                                      " / " +
                                                      enddatecontroller!.month
                                                          .toString() +
                                                      " / " +
                                                      enddatecontroller!.year
                                                          .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: API.textcolor,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              1200
                                                          ? 12
                                                          : 15,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      print("This is the salesman");
                                      print(selectedsalesman);

                                      if (startdatecontroller != null &&
                                          enddatecontroller != null) {
                                        setState(() {
                                          load = true;
                                        });
                                        final dynamic commisionresponse =
                                            await API.commisionReportListAPI(
                                                "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                selectedsalesman.isEmpty
                                                    ? "0"
                                                    : selectedsalesman["id"],
                                                widget.token);
                                        print("This is the response");
                                        print(commisionresponse);
                                        setState(() {
                                          commisionresponse["data"].length == 0
                                              ? selectedreport = {}
                                              : selectedreport["pdfurl"] =
                                                  commisionresponse["data_pdf"]
                                                      ["pdflink"];
                                          load = false;
                                        });
                                        print(selectedreport);
                                      } else {
                                        Get.snackbar(
                                            "Failed",
                                            "Please select date range"
                                                .toString(),
                                            backgroundColor: Colors.white,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            colorText: Colors.red);
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width <
                                              1200
                                          ? MediaQuery.of(context).size.width /
                                              7
                                          : MediaQuery.of(context).size.width /
                                              9,
                                      height: 48,
                                      child: Card(
                                        color: API.background,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: API.tilecolor)),
                                        elevation: 20,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: FaIcon(
                                                FontAwesomeIcons.file,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "Commision Report".toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: API.textcolor,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                1200
                                                            ? 12
                                                            : 15,
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
                                      print("This is the salesman");
                                      print(selectedsalesman);

                                      if (startdatecontroller != null &&
                                          enddatecontroller != null) {
                                        setState(() {
                                          load = true;
                                        });
                                        final dynamic commisionresponse = await API
                                            .detailedCommisionReportListAPI(
                                                "${startdatecontroller!.year}-${startdatecontroller!.month}-${startdatecontroller!.day}",
                                                "${enddatecontroller!.year}-${enddatecontroller!.month}-${enddatecontroller!.day}",
                                                selectedsalesman.isEmpty
                                                    ? "0"
                                                    : selectedsalesman["id"],
                                                widget.token);
                                        print("This is the response");
                                        print(commisionresponse);
                                        setState(() {
                                          commisionresponse["data"].length == 0
                                              ? selectedreport = {}
                                              : selectedreport["pdfurl"] =
                                                  commisionresponse["data_pdf"]
                                                      ["pdflink"];
                                          load = false;
                                        });
                                        print(selectedreport);
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width <
                                              1200
                                          ? MediaQuery.of(context).size.width /
                                              7
                                          : MediaQuery.of(context).size.width /
                                              9,
                                      height: 48,
                                      child: Card(
                                        color: API.background,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: API.tilecolor)),
                                        elevation: 20,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.filePdf,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "Detailed Report".toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: API.textcolor,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                1200
                                                            ? 12
                                                            : 15,
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
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Container(
                          color: Colors.white,
                          child: selectedreport.isEmpty
                              ? Center(
                                  child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              4,
                                      child: Lottie.asset(
                                          "assets/images/report.json")),
                                )
                              : SfPdfViewerTheme(
                                  data: SfPdfViewerThemeData(
                                    backgroundColor: API.background,
                                  ),
                                  child: SfPdfViewer.network(
                                    API.imgurl + selectedreport["pdfurl"],
                                    initialZoomLevel: 1.5,
                                  )),
                        )),
                  ))
                ],
              ),
      ),
    );
  }
}
