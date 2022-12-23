// import 'dart:typed_data';

// import 'package:esc_pos_printer/esc_pos_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:route_transitions/route_transitions.dart';
// import 'package:windowspos/api/api.dart';
// import 'package:windowspos/frontend/dashboard.dart';
// import 'package:windowspos/frontend/successpage.dart';
// import 'package:windowspos/models/locationmodel.dart';
// import 'package:windowspos/models/salesmanmodel.dart';
// import 'package:image/image.dart' as im;

// class Receipts extends StatefulWidget {
//   final String userid;
//   final String ipaddress;
//   final Map<String, dynamic> userdetails;
//   final String token;
//   const Receipts(
//       {Key? key,
//       required this.token,
//       required this.ipaddress,
//       required this.userdetails,
//       required this.userid})
//       : super(key: key);

//   @override
//   State<Receipts> createState() => _ReceiptsState();
// }

// class _ReceiptsState extends State<Receipts> {
//   TextEditingController selecteddate = TextEditingController();
//   TextEditingController receivedamountcontroller = TextEditingController();
//   TextEditingController authorizationcodecontroller = TextEditingController();

//   // Map<String, dynamic> salesman = {};
//   // Map<String, dynamic> location = {};

//   bool loading = false;
//   List<dynamic> invoicelist = [];
//   bool error = false;
//   String message = "";

//   Map<String, dynamic> selectedsalesman = {};
//   Map<String, dynamic> selectedlocation = {};
//   Map<String, dynamic> selectedreceipttype = {};
//   dynamic imagebytes;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//     Future.delayed(Duration(seconds: 0), () async {
//       print("inside init state");
//       final ByteData invoicedata = await rootBundle.load(
//         'assets/images/logo2.png',
//       );
//       final Uint8List logoimgBytes = invoicedata.buffer.asUint8List();
//       final dynamic logoimage = im.decodeImage(logoimgBytes);
//       setState(() {
//         loading = true;
//         imagebytes = logoimage;
//         selecteddate.text =
//             "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
//       });
//       final dynamic userdetailsresponse =
//           await API.getSalesmanQueryList("", widget.token);
//       print(userdetailsresponse);
//       final dynamic userdetailsid =
//           await API.indexOfList(userdetailsresponse, widget.userid.toString());
//       print("Selected data");
//       print(userdetailsid);
//       setState(() {
//         selectedsalesman = userdetailsid == -1
//             ? {}
//             : {
//                 "id": userdetailsresponse[userdetailsid].id,
//                 "name": userdetailsresponse[userdetailsid].name
//               };
//       });
//       final dynamic invoicelistresponse = await API.invoiceListAPI(
//           selecteddate.text,
//           selectedsalesman.isEmpty ? "" : selectedsalesman["id"],
//           selectedlocation.isEmpty ? "" : selectedlocation["id"],
//           widget.token);
//       if (invoicelistresponse["status"] == "success") {
//         setState(() {
//           invoicelist = invoicelistresponse["data"];
//           selectedreceipttype = receipttype[0];
//           loading = false;
//         });
//       } else {
//         setState(() {
//           error = true;
//           message = invoicelistresponse["message"].toString();
//           loading = false;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//   }

//   Map<String, dynamic>? selectedreceipt;
//   List<dynamic> receipttype = [
//     {"type": "Select", "code": ""},
//     {"type": "Cash", "code": "CH"},
//     {"type": "Card", "code": "CA"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: InkWell(
//           onTap: () async {
//             const PaperSize paper = PaperSize.mm80;
//             final profile = await CapabilityProfile.load();
//             final printer = NetworkPrinter(paper, profile);
//             try {
//               final res = await printer.connect('10.39.1.114', port: 9100);
//               printer.text(
//                   'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//               printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//                   styles: PosStyles(codeTable: 'CP1252'));
//               printer.text('Special 2: blåbærgrød',
//                   styles: PosStyles(codeTable: 'CP1252'));

//               printer.text('Bold text', styles: PosStyles(bold: true));
//               printer.text('Reverse text', styles: PosStyles(reverse: true));
//               printer.text('Underlined text',
//                   styles: PosStyles(underline: true), linesAfter: 1);
//               printer.text('Align left',
//                   styles: PosStyles(align: PosAlign.left));
//               printer.text('Align center',
//                   styles: PosStyles(align: PosAlign.center));
//               printer.text('Align right',
//                   styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//               printer.text('Text size 200%',
//                   styles: PosStyles(
//                     height: PosTextSize.size2,
//                     width: PosTextSize.size2,
//                   ));
//               printer.text(
//                   'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//               printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//                   styles: PosStyles(codeTable: 'CP1252'));
//               printer.text('Special 2: blåbærgrød',
//                   styles: PosStyles(codeTable: 'CP1252'));

//               printer.text('Bold text', styles: PosStyles(bold: true));
//               printer.text('Reverse text', styles: PosStyles(reverse: true));
//               printer.text('Underlined text',
//                   styles: PosStyles(underline: true), linesAfter: 1);
//               printer.text('Align left',
//                   styles: PosStyles(align: PosAlign.left));
//               printer.text('Align center',
//                   styles: PosStyles(align: PosAlign.center));
//               printer.text('Align right',
//                   styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//               printer.text('Text size 200%',
//                   styles: PosStyles(
//                     height: PosTextSize.size2,
//                     width: PosTextSize.size2,
//                   ));

//               printer.text(
//                   'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//               printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//                   styles: PosStyles(codeTable: 'CP1252'));
//               printer.text('Special 2: blåbærgrød',
//                   styles: PosStyles(codeTable: 'CP1252'));

//               printer.text('Bold text', styles: PosStyles(bold: true));
//               printer.text('Reverse text', styles: PosStyles(reverse: true));
//               printer.text('Underlined text',
//                   styles: PosStyles(underline: true), linesAfter: 1);
//               printer.text('Align left',
//                   styles: PosStyles(align: PosAlign.left));
//               printer.text('Align center',
//                   styles: PosStyles(align: PosAlign.center));
//               printer.text('Align right',
//                   styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//               printer.text('Text size 200%',
//                   styles: PosStyles(
//                     height: PosTextSize.size2,
//                     width: PosTextSize.size2,
//                   ));
//               printer.text(
//                   'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//               printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//                   styles: PosStyles(codeTable: 'CP1252'));
//               printer.text('Special 2: blåbærgrød',
//                   styles: PosStyles(codeTable: 'CP1252'));

//               printer.text('Bold text', styles: PosStyles(bold: true));
//               printer.text('Reverse text', styles: PosStyles(reverse: true));
//               printer.text('Underlined text',
//                   styles: PosStyles(underline: true), linesAfter: 1);
//               printer.text('Align left',
//                   styles: PosStyles(align: PosAlign.left));
//               printer.text('Align center',
//                   styles: PosStyles(align: PosAlign.center));
//               printer.text('Align right',
//                   styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//               printer.text('Text size 200%',
//                   styles: PosStyles(
//                     height: PosTextSize.size2,
//                     width: PosTextSize.size2,
//                   ));
//               printer.feed(2);
//               printer.cut();
//               printer.disconnect();
//             } catch (e) {
//               print(e);
//               // do stuff
//             }
//             // final PosPrintResult res =
//             //     await printer.connect('10.39.1.114', port: 9100);
//             // if (res == PosPrintResult.success) {
//             //   API.testReceipt(printer);
//             //   printer.disconnect();
//             // }
//           },
//           child: Text(
//             "Invoices",
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w400),
//           ),
//         ),
//       ),
//       body: loading
//           ? Center(
//               child: CircularProgressIndicator(
//                 color: Colors.red,
//                 strokeWidth: 1,
//               ),
//             )
//           : Container(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: Column(children: [
//                 SizedBox(
//                   height: 9,
//                 ),
//                 Container(
//                   height: MediaQuery.of(context).size.height / 7.8,
//                   width: MediaQuery.of(context).size.width,
//                   // color: Colors.yellow,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Date".toUpperCase(),
//                                     textAlign: TextAlign.start,
//                                     style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Montserrat'),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               margin:
//                                   const EdgeInsets.only(left: 20, right: 20),
//                               width: MediaQuery.of(context).size.width / 5,
//                               child: TextField(
//                                   controller: selecteddate,
//                                   keyboardType: TextInputType.name,
//                                   style: TextStyle(
//                                       color: API.textcolor,
//                                       fontWeight: FontWeight.w400),
//                                   readOnly: true,
//                                   onTap: () async {
//                                     DateTime? pickedDate = await showDatePicker(
//                                       builder: (context, child) {
//                                         return Theme(
//                                           data: Theme.of(context).copyWith(
//                                             colorScheme: ColorScheme.light(
//                                               primary: Colors.red,
//                                               onPrimary: Colors.white,
//                                               onSurface: Colors.blueAccent,
//                                             ),
//                                             textButtonTheme:
//                                                 TextButtonThemeData(
//                                               style: TextButton.styleFrom(
//                                                 primary: Colors.green[700],
//                                               ),
//                                             ),
//                                           ),
//                                           child: child!,
//                                         );
//                                       },
//                                       context: context,
//                                       initialDate: DateTime.now(),
//                                       firstDate: DateTime(1950),
//                                       lastDate: DateTime(2100),
//                                     );
//                                     if (pickedDate != null) {
//                                       setState(() {
//                                         loading = true;
//                                         selecteddate.text =
//                                             "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
//                                       });
//                                       final dynamic invoicelistresponse =
//                                           await API.invoiceListAPI(
//                                               selecteddate.text,
//                                               selectedsalesman.isEmpty
//                                                   ? ""
//                                                   : selectedsalesman["id"],
//                                               selectedlocation.isEmpty
//                                                   ? ""
//                                                   : selectedlocation["id"],
//                                               widget.token);
//                                       if (invoicelistresponse["status"] ==
//                                           "success") {
//                                         setState(() {
//                                           invoicelist =
//                                               invoicelistresponse["data"];
//                                           loading = false;
//                                         });
//                                       } else {
//                                         setState(() {
//                                           loading = false;
//                                         });
//                                         Get.snackbar(
//                                             "Failed",
//                                             invoicelistresponse["message"]
//                                                 .toString(),
//                                             backgroundColor: Colors.white,
//                                             colorText: Colors.red);
//                                       }
//                                     } else {
//                                       Get.snackbar(
//                                           "Failed", "Please select a date",
//                                           backgroundColor: Colors.white,
//                                           colorText: Colors.red);
//                                     }
//                                   },
//                                   decoration: InputDecoration(
//                                       filled: true,
//                                       fillColor: const Color.fromRGBO(
//                                           248, 248, 253, 1),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(5.0),
//                                         borderSide: BorderSide(
//                                           color: Colors.black.withOpacity(0.5),
//                                           width: 1.0,
//                                         ),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(5.0),
//                                         borderSide: const BorderSide(
//                                           color: Colors.green,
//                                           width: 1.0,
//                                         ),
//                                       ),
//                                       hintStyle: const TextStyle(
//                                           fontFamily: 'Montserrat',
//                                           color:
//                                               Color.fromRGBO(181, 184, 203, 1),
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 12),
//                                       contentPadding: const EdgeInsets.fromLTRB(
//                                           20.0, 10.0, 20.0, 10.0),
//                                       hintText: "Date",
//                                       border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5.0)))),
//                             ),
//                           ]),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Salesman".toUpperCase(),
//                                     textAlign: TextAlign.start,
//                                     style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Montserrat'),
//                                   ),
//                                 ],
//                               ),
//                               selectedsalesman.isNotEmpty
//                                   ? Container(
//                                       width: MediaQuery.of(context).size.width /
//                                           3.5,
//                                       height: 48,
//                                       decoration: BoxDecoration(
//                                           // border:
//                                           color: const Color.fromRGBO(
//                                               248, 248, 253, 1),
//                                           borderRadius:
//                                               BorderRadius.circular(4.0),
//                                           border: Border.all(
//                                               color: Colors.green, width: 1.0)),
//                                       child: Padding(
//                                         padding: const EdgeInsets.fromLTRB(
//                                             20.0, 15.0, 20.0, 15.0),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Container(
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width /
//                                                   4.2,
//                                               child: Text(
//                                                 selectedsalesman['name']
//                                                     .toString()
//                                                     .toString()
//                                                     .toUpperCase(),
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     color: API.textcolor,
//                                                     fontWeight: FontWeight.w400,
//                                                     fontSize: 14),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                   : Container(
//                                       height: 48,
//                                       width: MediaQuery.of(context).size.width /
//                                           3.5,
//                                       child: TypeAheadField(
//                                           textFieldConfiguration:
//                                               TextFieldConfiguration(
//                                             style: TextStyle(
//                                                 color: API.textcolor,
//                                                 fontWeight: FontWeight.w400),
//                                             decoration: InputDecoration(
//                                                 filled: true,
//                                                 fillColor: const Color.fromRGBO(
//                                                     248, 248, 253, 1),
//                                                 enabledBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                   borderSide: BorderSide(
//                                                     color: API.bordercolor,
//                                                     width: 1.0,
//                                                   ),
//                                                 ),
//                                                 focusedBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                   borderSide: const BorderSide(
//                                                     color: Colors.green,
//                                                     width: 1.0,
//                                                   ),
//                                                 ),
//                                                 hintStyle: const TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     color: Color.fromRGBO(
//                                                         181, 184, 203, 1),
//                                                     fontWeight: FontWeight.w500,
//                                                     fontSize: 14),
//                                                 contentPadding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         10.0, 10.0, 10.0, 10.0),
//                                                 // ignore: unnecessary_null_comparison
//                                                 hintText: 'Enter Salesman',
//                                                 border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             4.0))),
//                                           ),
//                                           suggestionsCallback: (value) async {
//                                             if (value == null) {
//                                               return await API
//                                                   .getSalesmanQueryList(
//                                                       value, widget.token);
//                                             } else {
//                                               return await API
//                                                   .getSalesmanQueryList(
//                                                       value, widget.token);
//                                             }
//                                           },
//                                           itemBuilder: (context,
//                                               SalesManSchema? itemslist) {
//                                             final listdata = itemslist;
//                                             return ListTile(
//                                               title: Text(
//                                                 "${listdata!.name.toUpperCase()}",
//                                                 overflow: TextOverflow.ellipsis,
//                                                 softWrap: false,
//                                                 maxLines: 1,
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     color: API.textcolor,
//                                                     fontWeight: FontWeight.w500,
//                                                     fontSize: 14),
//                                               ),
//                                             );
//                                           },
//                                           onSuggestionSelected: (SalesManSchema?
//                                               itemslist) async {
//                                             final data = {
//                                               'id': itemslist!.id,
//                                               'name': itemslist.name,
//                                             };
//                                             setState(() {
//                                               loading = true;
//                                               selectedsalesman = data;
//                                             });
//                                             final dynamic invoicelistresponse =
//                                                 await API.invoiceListAPI(
//                                                     selecteddate.text,
//                                                     selectedsalesman.isEmpty
//                                                         ? ""
//                                                         : selectedsalesman[
//                                                             "id"],
//                                                     selectedlocation.isEmpty
//                                                         ? ""
//                                                         : selectedlocation[
//                                                             "id"],
//                                                     widget.token);
//                                             print(invoicelistresponse);
//                                             if (invoicelistresponse["status"] ==
//                                                 "success") {
//                                               setState(() {
//                                                 invoicelist =
//                                                     invoicelistresponse["data"];
//                                                 loading = false;
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 loading = false;
//                                               });
//                                               Get.snackbar(
//                                                   "Failed",
//                                                   invoicelistresponse["message"]
//                                                       .toString(),
//                                                   backgroundColor: Colors.white,
//                                                   colorText: Colors.red);
//                                             }
//                                             print(selectedsalesman);
//                                           }),
//                                     ),
//                             ],
//                           ),
//                           RawMaterialButton(
//                             onPressed: () {
//                               setState(() {
//                                 selectedsalesman = {};
//                               });
//                             },
//                             elevation: 2.0,
//                             fillColor: Colors.red,
//                             padding: const EdgeInsets.all(10.0),
//                             shape: const CircleBorder(
//                                 side: BorderSide(color: Colors.white)),
//                             child: const FaIcon(
//                               FontAwesomeIcons.close,
//                               color: Colors.white,
//                               size: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Location".toUpperCase(),
//                                     textAlign: TextAlign.start,
//                                     style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Montserrat'),
//                                   ),
//                                 ],
//                               ),
//                               selectedlocation.isNotEmpty
//                                   ? Container(
//                                       width: MediaQuery.of(context).size.width /
//                                           3.5,
//                                       height: 48,
//                                       decoration: BoxDecoration(
//                                           // border:
//                                           color: const Color.fromRGBO(
//                                               248, 248, 253, 1),
//                                           borderRadius:
//                                               BorderRadius.circular(4.0),
//                                           border: Border.all(
//                                               color: Colors.green, width: 1.0)),
//                                       child: Padding(
//                                         padding: const EdgeInsets.fromLTRB(
//                                             20.0, 15.0, 20.0, 15.0),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Container(
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width /
//                                                   4.2,
//                                               child: Text(
//                                                 selectedlocation['name']
//                                                     .toString()
//                                                     .toString()
//                                                     .toUpperCase(),
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     color: API.textcolor,
//                                                     fontWeight: FontWeight.w400,
//                                                     fontSize: 14),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                   : Container(
//                                       height: 48,
//                                       width: MediaQuery.of(context).size.width /
//                                           3.5,
//                                       child: TypeAheadField(
//                                           textFieldConfiguration:
//                                               TextFieldConfiguration(
//                                             style: TextStyle(
//                                                 color: API.textcolor,
//                                                 fontWeight: FontWeight.w400),
//                                             decoration: InputDecoration(
//                                                 filled: true,
//                                                 fillColor: const Color.fromRGBO(
//                                                     248, 248, 253, 1),
//                                                 enabledBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                   borderSide: BorderSide(
//                                                     color: API.bordercolor,
//                                                     width: 1.0,
//                                                   ),
//                                                 ),
//                                                 focusedBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                   borderSide: const BorderSide(
//                                                     color: Colors.green,
//                                                     width: 1.0,
//                                                   ),
//                                                 ),
//                                                 hintStyle: const TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     color: Color.fromRGBO(
//                                                         181, 184, 203, 1),
//                                                     fontWeight: FontWeight.w500,
//                                                     fontSize: 14),
//                                                 contentPadding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         10.0, 10.0, 10.0, 10.0),
//                                                 // ignore: unnecessary_null_comparison
//                                                 hintText: 'Enter Location',
//                                                 border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             4.0))),
//                                           ),
//                                           suggestionsCallback: (value) async {
//                                             if (value == null) {
//                                               return await API
//                                                   .getLocationsQueryList(
//                                                       value, widget.token);
//                                             } else {
//                                               return await API
//                                                   .getLocationsQueryList(
//                                                       value, widget.token);
//                                             }
//                                           },
//                                           itemBuilder: (context,
//                                               LocationSchema? itemslist) {
//                                             final listdata = itemslist;
//                                             return ListTile(
//                                               title: Text(
//                                                 "${listdata!.name.toUpperCase()}",
//                                                 overflow: TextOverflow.ellipsis,
//                                                 softWrap: false,
//                                                 maxLines: 1,
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     color: API.textcolor,
//                                                     fontWeight: FontWeight.w500,
//                                                     fontSize: 14),
//                                               ),
//                                             );
//                                           },
//                                           onSuggestionSelected: (LocationSchema?
//                                               itemslist) async {
//                                             final data = {
//                                               'id': itemslist!.id,
//                                               'name': itemslist.name,
//                                             };
//                                             setState(() {
//                                               loading = true;
//                                               selectedlocation = data;
//                                             });
//                                             final dynamic invoicelistresponse =
//                                                 await API.invoiceListAPI(
//                                                     selecteddate.text,
//                                                     selectedsalesman.isEmpty
//                                                         ? ""
//                                                         : selectedsalesman[
//                                                             "id"],
//                                                     selectedlocation.isEmpty
//                                                         ? ""
//                                                         : selectedlocation[
//                                                             "id"],
//                                                     widget.token);
//                                             print(invoicelistresponse);
//                                             if (invoicelistresponse["status"] ==
//                                                 "success") {
//                                               setState(() {
//                                                 invoicelist =
//                                                     invoicelistresponse["data"];
//                                                 loading = false;
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 loading = false;
//                                               });
//                                               Get.snackbar(
//                                                   "Failed",
//                                                   invoicelistresponse["message"]
//                                                       .toString(),
//                                                   backgroundColor: Colors.white,
//                                                   colorText: Colors.red);
//                                             }
//                                             print(selectedlocation);
//                                           }),
//                                     ),
//                             ],
//                           ),
//                           RawMaterialButton(
//                             onPressed: () {
//                               setState(() {
//                                 selectedlocation = {};
//                               });
//                             },
//                             elevation: 2.0,
//                             fillColor: Colors.red,
//                             padding: const EdgeInsets.all(10.0),
//                             shape: const CircleBorder(
//                                 side: BorderSide(color: Colors.white)),
//                             child: const FaIcon(
//                               FontAwesomeIcons.close,
//                               color: Colors.white,
//                               size: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(
//                   color: API.bordercolor,
//                 ),
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width / 2,
//                         child: invoicelist.isEmpty
//                             ? Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(20.0),
//                                   child: Image.asset("assets/images/box.png"),
//                                 ),
//                               )
//                             : ListView.separated(
//                                 itemCount: invoicelist.length,
//                                 itemBuilder: (context, index) {
//                                   return ListTile(
//                                     onTap: () {
//                                       setState(() {
//                                         selectedreceipt = invoicelist[index];
//                                       });
//                                     },
//                                     leading: Container(
//                                       height: 40,
//                                       width: 30,
//                                       child: Center(
//                                         child: Text(
//                                           (index + 1).toString(),
//                                           textAlign: TextAlign.start,
//                                           style: TextStyle(
//                                               color: Colors.amber,
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w800,
//                                               fontFamily: 'Montserrat'),
//                                         ),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       invoicelist[index]["id"].toUpperCase(),
//                                       textAlign: TextAlign.start,
//                                       style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w600,
//                                           fontFamily: 'Montserrat'),
//                                     ),
//                                     subtitle: Text(
//                                       invoicelist[index]["customer_name"]
//                                           .toUpperCase(),
//                                       textAlign: TextAlign.start,
//                                       style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600,
//                                           fontFamily: 'Montserrat'),
//                                     ),
//                                     trailing: Container(
//                                       // color: Colors.yellow,
//                                       width: MediaQuery.of(context).size.width /
//                                           3.5,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceAround,
//                                         children: [
//                                           Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(vertical: 5),
//                                                     child: Text(
//                                                       "Total",
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 12,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                           fontFamily:
//                                                               'Montserrat'),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Text(
//                                                 "AED : ${((double.parse(invoicelist[index]["grand_total"]) - double.parse(invoicelist[index]["vat_amount"]))).toStringAsFixed(2).toUpperCase()}",
//                                                 textAlign: TextAlign.start,
//                                                 style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontFamily: 'Montserrat'),
//                                               ),
//                                             ],
//                                           ),
//                                           Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(vertical: 5),
//                                                     child: Text(
//                                                       "VAT",
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 12,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                           fontFamily:
//                                                               'Montserrat'),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Text(
//                                                 "AED : ${double.parse(invoicelist[index]["vat_amount"]).toStringAsFixed(2).toUpperCase()}",
//                                                 textAlign: TextAlign.start,
//                                                 style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontFamily: 'Montserrat'),
//                                               ),
//                                             ],
//                                           ),
//                                           Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(vertical: 5),
//                                                     child: Text(
//                                                       "Grand Total",
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 12,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                           fontFamily:
//                                                               'Montserrat'),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Text(
//                                                 "AED : ${double.parse(invoicelist[index]["grand_total"]).toStringAsFixed(2).toUpperCase()}",
//                                                 textAlign: TextAlign.start,
//                                                 style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontFamily: 'Montserrat'),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 separatorBuilder:
//                                     (BuildContext context, int index) {
//                                   return Divider(
//                                     color: API.bordercolor.withOpacity(0.8),
//                                   );
//                                 },
//                               ),
//                       ),
//                       VerticalDivider(
//                         color: API.bordercolor,
//                         width: 1,
//                       ),
//                       Expanded(
//                           child: Container(
//                               // color: Colors.yellow,
//                               child: selectedreceipt == null
//                                   ? Container(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 10),
//                                             child: FaIcon(
//                                               FontAwesomeIcons.cubes,
//                                               color: Colors.red,
//                                               size: 80,
//                                             ),
//                                           ),
//                                           Text(
//                                             "Please a select receipt",
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontFamily: 'Montserrat'),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : Container(
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Container(
//                                               child: Column(
//                                                 children: [
//                                                   Container(
//                                                     height: 50,
//                                                     color: Colors.red,
//                                                     child: Row(
//                                                       children: [
//                                                         Container(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               11,
//                                                           // color: Colors.green,
//                                                           child: Text(
//                                                             "Item Code",
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize: 10,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                         ),
//                                                         Expanded(
//                                                             child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceEvenly,
//                                                           children: [
//                                                             Text(
//                                                               "Rate",
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                             Text(
//                                                               "Qty",
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                             Text(
//                                                               "Unit",
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                             Text(
//                                                               "Amount",
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                           ],
//                                                         ))
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                       child: Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             left: 5, right: 5),
//                                                     child: ListView.builder(
//                                                         itemCount:
//                                                             selectedreceipt![
//                                                                     "items"]
//                                                                 .length,
//                                                         itemBuilder:
//                                                             (context, index) {
//                                                           return Container(
//                                                             height: 50,
//                                                             // color: Colors.red,
//                                                             child: Row(
//                                                               children: [
//                                                                 Container(
//                                                                   width: MediaQuery.of(
//                                                                               context)
//                                                                           .size
//                                                                           .width /
//                                                                       11,
//                                                                   // color: Colors.green,
//                                                                   child: Text(
//                                                                     selectedreceipt!["items"]
//                                                                             [
//                                                                             index]
//                                                                         [
//                                                                         "part_number"],
//                                                                     style: TextStyle(
//                                                                         color: Colors
//                                                                             .black,
//                                                                         fontSize:
//                                                                             10,
//                                                                         fontFamily:
//                                                                             'Montserrat'),
//                                                                   ),
//                                                                 ),
//                                                                 Expanded(
//                                                                     child: Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceEvenly,
//                                                                   children: [
//                                                                     Text(
//                                                                       double.parse(selectedreceipt!["items"][index]
//                                                                               [
//                                                                               "rate"])
//                                                                           .toStringAsFixed(
//                                                                               2),
//                                                                       style: TextStyle(
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               10,
//                                                                           fontFamily:
//                                                                               'Montserrat'),
//                                                                     ),
//                                                                     Text(
//                                                                       double.parse(selectedreceipt!["items"][index]
//                                                                               [
//                                                                               "quantity"])
//                                                                           .toStringAsFixed(
//                                                                               0),
//                                                                       style: TextStyle(
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               10,
//                                                                           fontFamily:
//                                                                               'Montserrat'),
//                                                                     ),
//                                                                     Text(
//                                                                       selectedreceipt!["items"][index]
//                                                                               [
//                                                                               "unit_name"]
//                                                                           .toString(),
//                                                                       style: TextStyle(
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               10,
//                                                                           fontFamily:
//                                                                               'Montserrat'),
//                                                                     ),
//                                                                     Text(
//                                                                       double.parse(selectedreceipt!["items"][index]
//                                                                               [
//                                                                               "total_amount"])
//                                                                           .toStringAsFixed(
//                                                                               2),
//                                                                       style: TextStyle(
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               10,
//                                                                           fontFamily:
//                                                                               'Montserrat'),
//                                                                     ),
//                                                                   ],
//                                                                 )),
//                                                               ],
//                                                             ),
//                                                           );
//                                                         }),
//                                                   )),
//                                                   selectedreceipt![
//                                                               "receipt_flag"] ==
//                                                           1
//                                                       ? GestureDetector(
//                                                           onTap: () async {
//                                                             if (selectedreceipttype[
//                                                                     "code"] ==
//                                                                 "") {
//                                                               Get.snackbar(
//                                                                   "Failed",
//                                                                   "Please select a receipt type",
//                                                                   backgroundColor:
//                                                                       Colors
//                                                                           .white,
//                                                                   colorText:
//                                                                       Colors
//                                                                           .red);
//                                                             } else {
//                                                               if (receivedamountcontroller
//                                                                   .text
//                                                                   .isEmpty) {
//                                                                 Get.snackbar(
//                                                                     "Failed",
//                                                                     "Please enter received amount",
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .white,
//                                                                     colorText:
//                                                                         Colors
//                                                                             .red);
//                                                               } else {
//                                                                 if (double.parse(
//                                                                         receivedamountcontroller
//                                                                             .text) >=
//                                                                     double.parse(
//                                                                         selectedreceipt![
//                                                                             "grand_total"])) {
//                                                                   setState(() {
//                                                                     loading =
//                                                                         true;
//                                                                   });
//                                                                   final dynamic updateinvoiceresponse = await API.updateInvoiceAPI(
//                                                                       selectedreceipt![
//                                                                           "id"],
//                                                                       selectedreceipttype[
//                                                                           "code"],
//                                                                       selectedreceipt![
//                                                                           "grand_total"],
//                                                                       authorizationcodecontroller
//                                                                           .text,
//                                                                       widget
//                                                                           .token);
//                                                                   if (updateinvoiceresponse[
//                                                                           "status"] ==
//                                                                       "success") {
//                                                                     pushWidgetWhileRemove(
//                                                                         newPage: SuccessPage(
//                                                                             screen:
//                                                                                 dashboard()),
//                                                                         context:
//                                                                             context);
//                                                                   } else {
//                                                                     Get.snackbar(
//                                                                         "Failed",
//                                                                         updateinvoiceresponse["message"]
//                                                                             .toString(),
//                                                                         backgroundColor:
//                                                                             Colors
//                                                                                 .white,
//                                                                         colorText:
//                                                                             Colors.red);
//                                                                   }
//                                                                 } else {
//                                                                   Get.snackbar(
//                                                                       "Failed",
//                                                                       "Please enter received amount greater than or equal to grand total",
//                                                                       backgroundColor:
//                                                                           Colors
//                                                                               .white,
//                                                                       colorText:
//                                                                           Colors
//                                                                               .red);
//                                                                 }
//                                                               }
//                                                             }
//                                                           },
//                                                           child: Card(
//                                                             color: Colors.amber,
//                                                             elevation: 20,
//                                                             child: Container(
//                                                               height: 40,
//                                                               child: Center(
//                                                                 child: Text(
//                                                                   "UPDATE & PRINT",
//                                                                   style: TextStyle(
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontSize:
//                                                                           14,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600,
//                                                                       fontFamily:
//                                                                           'Montserrat'),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         )
//                                                       : GestureDetector(
//                                                           onTap: () async {
//                                                             const PaperSize
//                                                                 paper =
//                                                                 PaperSize.mm80;
//                                                             final profile =
//                                                                 await CapabilityProfile
//                                                                     .load();
//                                                             final printer =
//                                                                 NetworkPrinter(
//                                                                     paper,
//                                                                     profile);
                                                        
//                                                             API.printInvoice(
//                                                               widget.ipaddress,
//                                                                 printer,
//                                                                 selectedreceipt![
//                                                                     "items"],
//                                                                 (double.parse(selectedreceipt!["grand_total"].toString()) -
//                                                                         double.parse(selectedreceipt!["vat_amount"]
//                                                                             .toString()))
//                                                                     .toStringAsFixed(
//                                                                         2),
//                                                                 selectedreceipt![
//                                                                         "vat_amount"]
//                                                                     .toString(),
//                                                                 imagebytes,
//                                                                 selectedreceipt![
//                                                                     "invoice_no"],
//                                                                 selectedreceipt![
//                                                                     "customer_name"],
//                                                                 selectedreceipt![
//                                                                     "invoice_date"],
//                                                                 selectedreceipt![
//                                                                     "warehouse_name"],
//                                                                 selectedreceipt![
//                                                                         "grand_total"]
//                                                                     .toString(),
//                                                                 widget.userdetails[
//                                                                     "company_name"],
//                                                                 widget.userdetails[
//                                                                     "billing_address"],
//                                                                 widget.userdetails[
//                                                                     "genral_phno"],
//                                                                 selectedreceipt![
//                                                                     "customer_phone"],
//                                                                 selectedreceipt![
//                                                                     "sales_man"],
//                                                                 selectedreceipt!["receipt_type"] == "CH"
//                                                                     ? "CASH"
//                                                                     : "CARD",
//                                                                 selectedreceipt![
//                                                                     "received_amount"]);
//                                                             printer
//                                                                 .disconnect();
//                                                             setState(() {
//                                                               loading = false;
//                                                             });
                                                           
//                                                           },
//                                                           child: Card(
//                                                             color: Colors.green,
//                                                             elevation: 20,
//                                                             child: Container(
//                                                               height: 40,
//                                                               child: Center(
//                                                                 child: Text(
//                                                                   "PRINT RECEIPT",
//                                                                   style: TextStyle(
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontSize:
//                                                                           14,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600,
//                                                                       fontFamily:
//                                                                           'Montserrat'),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           VerticalDivider(
//                                             color: API.bordercolor,
//                                             width: 1,
//                                           ),
//                                           Column(
//                                             children: [
//                                               Container(
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width /
//                                                     5.5,
//                                                 // color: Colors.red,
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           left: 5),
//                                                   child: SingleChildScrollView(
//                                                     child: selectedreceipt![
//                                                                 "receipt_flag"] ==
//                                                             0
//                                                         ? Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               SizedBox(
//                                                                 height: 8,
//                                                               ),
//                                                               Text(
//                                                                 "Receipt Type",
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .black,
//                                                                     fontSize:
//                                                                         12,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600,
//                                                                     fontFamily:
//                                                                         'Montserrat'),
//                                                               ),
//                                                               Text(
//                                                                 selectedreceipt!["receipt_type"]
//                                                                             .toString() ==
//                                                                         "CH"
//                                                                     ? "CASH"
//                                                                     : "CARD",
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .black,
//                                                                     fontSize:
//                                                                         15,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w400,
//                                                                     fontFamily:
//                                                                         'Montserrat'),
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 8,
//                                                               ),
//                                                               Text(
//                                                                 "Received Amount",
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .black,
//                                                                     fontSize:
//                                                                         12,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600,
//                                                                     fontFamily:
//                                                                         'Montserrat'),
//                                                               ),
//                                                               Text(
//                                                                 selectedreceipt!["received_amount"]
//                                                                             .toString() ==
//                                                                         ""
//                                                                     ? "NA"
//                                                                     : double.parse(selectedreceipt!["received_amount"]
//                                                                             .toString())
//                                                                         .toStringAsFixed(
//                                                                             2),
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .black,
//                                                                     fontSize:
//                                                                         15,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w400,
//                                                                     fontFamily:
//                                                                         'Montserrat'),
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 8,
//                                                               ),
//                                                               selectedreceipt![
//                                                                               "receipt_type"]
//                                                                           .toString() ==
//                                                                       "CH"
//                                                                   ? SizedBox()
//                                                                   : Text(
//                                                                       "Authorization Code",
//                                                                       textAlign:
//                                                                           TextAlign
//                                                                               .start,
//                                                                       style: TextStyle(
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               12,
//                                                                           fontWeight: FontWeight
//                                                                               .w600,
//                                                                           fontFamily:
//                                                                               'Montserrat'),
//                                                                     ),
//                                                               selectedreceipt![
//                                                                               "receipt_type"]
//                                                                           .toString() ==
//                                                                       "CH"
//                                                                   ? SizedBox()
//                                                                   : Text(
//                                                                       selectedreceipt![
//                                                                               "authorization_code"]
//                                                                           .toString(),
//                                                                       textAlign:
//                                                                           TextAlign
//                                                                               .start,
//                                                                       style: TextStyle(
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               15,
//                                                                           fontWeight: FontWeight
//                                                                               .w400,
//                                                                           fontFamily:
//                                                                               'Montserrat'),
//                                                                     ),
//                                                             ],
//                                                           )
//                                                         : Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               SizedBox(
//                                                                 height: 2,
//                                                               ),
//                                                               // Text(
//                                                               //   "No of items",
//                                                               //   textAlign:
//                                                               //       TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 12,
//                                                               //       fontWeight:
//                                                               //           FontWeight.w600,
//                                                               //       fontFamily:
//                                                               //           'Montserrat'),
//                                                               // ),
//                                                               // Text(
//                                                               //   "2".toString(),
//                                                               //   textAlign:
//                                                               //       TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 13,
//                                                               //       fontWeight:
//                                                               //           FontWeight.w400,
//                                                               //       fontFamily:
//                                                               //           'Montserrat'),
//                                                               // ),
//                                                               // SizedBox(height: 10),
//                                                               // Text(
//                                                               //   "Total (before discount)",
//                                                               //   textAlign: TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 12,
//                                                               //       fontWeight: FontWeight.w600,
//                                                               //       fontFamily: 'Montserrat'),
//                                                               // ),
//                                                               // Text(
//                                                               //   model.totalPriceBefore.toString(),
//                                                               //   textAlign: TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 13,
//                                                               //       fontWeight: FontWeight.w400,
//                                                               //       fontFamily: 'Montserrat'),
//                                                               // ),
//                                                               // SizedBox(height: 10),
//                                                               // Text(
//                                                               //   "Discount",
//                                                               //   textAlign: TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 12,
//                                                               //       fontWeight: FontWeight.w600,
//                                                               //       fontFamily: 'Montserrat'),
//                                                               // ),
//                                                               // Text(
//                                                               //   model.totaldiscount.toString(),
//                                                               //   textAlign: TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 13,
//                                                               //       fontWeight: FontWeight.w400,
//                                                               //       fontFamily: 'Montserrat'),
//                                                               // ),
//                                                               // SizedBox(height: 3),
//                                                               // Text(
//                                                               //   "Sub Total",
//                                                               //   textAlign:
//                                                               //       TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 12,
//                                                               //       fontWeight:
//                                                               //           FontWeight.w600,
//                                                               //       fontFamily:
//                                                               //           'Montserrat'),
//                                                               // ),
//                                                               // Text(
//                                                               //   "12",
//                                                               //   textAlign:
//                                                               //       TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 13,
//                                                               //       fontWeight:
//                                                               //           FontWeight.w400,
//                                                               //       fontFamily:
//                                                               //           'Montserrat'),
//                                                               // ),
//                                                               // SizedBox(height: 3),
//                                                               // Text(
//                                                               //   "vat",
//                                                               //   textAlign:
//                                                               //       TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 12,
//                                                               //       fontWeight:
//                                                               //           FontWeight.w600,
//                                                               //       fontFamily:
//                                                               //           'Montserrat'),
//                                                               // ),
//                                                               // Text(
//                                                               //   "14",
//                                                               //   textAlign:
//                                                               //       TextAlign.start,
//                                                               //   style: TextStyle(
//                                                               //       color: Colors.black,
//                                                               //       fontSize: 13,
//                                                               //       fontWeight:
//                                                               //           FontWeight.w400,
//                                                               //       fontFamily:
//                                                               //           'Montserrat'),
//                                                               // ),
//                                                               // SizedBox(
//                                                               //   height: 2,
//                                                               // ),
//                                                               // Divider(
//                                                               //   color: API.bordercolor,
//                                                               // ),
//                                                               // SizedBox(
//                                                               //   height: 2,
//                                                               // ),
//                                                               Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceAround,
//                                                                 children: [
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         top: 2,
//                                                                         bottom:
//                                                                             4),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         Text(
//                                                                           "Receipt Type"
//                                                                               .toUpperCase(),
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.black,
//                                                                               fontSize: 10,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   Container(
//                                                                     width: MediaQuery.of(context)
//                                                                             .size
//                                                                             .width /
//                                                                         6,
//                                                                     height: 40,
//                                                                     child:
//                                                                         InputDecorator(
//                                                                       decoration: InputDecoration(
//                                                                           filled: true,
//                                                                           fillColor: const Color.fromRGBO(248, 248, 253, 1),
//                                                                           enabledBorder: OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(4.0),
//                                                                             borderSide:
//                                                                                 BorderSide(
//                                                                               color: API.bordercolor,
//                                                                               width: 1.0,
//                                                                             ),
//                                                                           ),
//                                                                           focusedBorder: OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(4.0),
//                                                                             borderSide:
//                                                                                 const BorderSide(
//                                                                               color: Colors.green,
//                                                                               width: 1.0,
//                                                                             ),
//                                                                           ),
//                                                                           hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
//                                                                           contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//                                                                           // ignore: unnecessary_null_comparison
//                                                                           hintText: 'Receipt Type',
//                                                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
//                                                                       child:
//                                                                           DropdownButtonHideUnderline(
//                                                                         child: DropdownButton<
//                                                                             dynamic>(
//                                                                           isExpanded:
//                                                                               true,
//                                                                           dropdownColor:
//                                                                               Colors.white,
//                                                                           hint:
//                                                                               const Text(
//                                                                             'Choose Type',
//                                                                             style: TextStyle(
//                                                                                 color: Color.fromRGBO(135, 141, 186, 1),
//                                                                                 fontFamily: 'Montserrat',
//                                                                                 fontWeight: FontWeight.w600,
//                                                                                 fontSize: 14),
//                                                                           ),
//                                                                           value:
//                                                                               selectedreceipttype,
//                                                                           isDense:
//                                                                               true,
//                                                                           onChanged:
//                                                                               (data) async {
//                                                                             setState(() {
//                                                                               selectedreceipttype = data;
//                                                                             });
//                                                                           },
//                                                                           items:
//                                                                               receipttype.map((value) {
//                                                                             return DropdownMenuItem<dynamic>(
//                                                                                 value: value,
//                                                                                 child: Container(
//                                                                                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
//                                                                                   height: 20.0,
//                                                                                   padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
//                                                                                   child: Container(
//                                                                                     child: Text(
//                                                                                       value['type'].toString().toUpperCase(),
//                                                                                       style: TextStyle(fontFamily: 'Montserrat', color: API.textcolor, fontWeight: FontWeight.w500, fontSize: 14),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ));
//                                                                           }).toList(),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceAround,
//                                                                 children: [
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         top: 2,
//                                                                         bottom:
//                                                                             4),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         Text(
//                                                                           "Received Amount"
//                                                                               .toUpperCase(),
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.black,
//                                                                               fontSize: 10,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   Container(
//                                                                     width: MediaQuery.of(context)
//                                                                             .size
//                                                                             .width /
//                                                                         6,
//                                                                     height: 40,
//                                                                     // color: Colors.red,
//                                                                     child:
//                                                                         TextFormField(
//                                                                       controller:
//                                                                           receivedamountcontroller,
//                                                                       keyboardType:
//                                                                           TextInputType
//                                                                               .number,
//                                                                       style: TextStyle(
//                                                                           color: API
//                                                                               .textcolor,
//                                                                           fontWeight:
//                                                                               FontWeight.w400),
//                                                                       decoration: InputDecoration(
//                                                                           filled: true,
//                                                                           fillColor: const Color.fromRGBO(248, 248, 253, 1),
//                                                                           enabledBorder: OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(4.0),
//                                                                             borderSide:
//                                                                                 BorderSide(
//                                                                               color: API.bordercolor,
//                                                                               width: 1.0,
//                                                                             ),
//                                                                           ),
//                                                                           focusedBorder: OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(4.0),
//                                                                             borderSide:
//                                                                                 const BorderSide(
//                                                                               color: Colors.green,
//                                                                               width: 1.0,
//                                                                             ),
//                                                                           ),
//                                                                           hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
//                                                                           contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//                                                                           // ignore: unnecessary_null_comparison
//                                                                           hintText: 'Received Amount',
//                                                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               selectedreceipttype[
//                                                                           "code"] ==
//                                                                       "CA"
//                                                                   ? Column(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .spaceAround,
//                                                                       children: [
//                                                                         Padding(
//                                                                           padding: const EdgeInsets.only(
//                                                                               top: 2,
//                                                                               bottom: 4),
//                                                                           child:
//                                                                               Row(
//                                                                             mainAxisAlignment:
//                                                                                 MainAxisAlignment.start,
//                                                                             children: [
//                                                                               Text(
//                                                                                 "Authorization Code".toUpperCase(),
//                                                                                 textAlign: TextAlign.start,
//                                                                                 style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                         Container(
//                                                                           width:
//                                                                               MediaQuery.of(context).size.width / 6,
//                                                                           height:
//                                                                               40,
//                                                                           // color: Colors.red,
//                                                                           child:
//                                                                               TextFormField(
//                                                                             controller:
//                                                                                 authorizationcodecontroller,
//                                                                             keyboardType:
//                                                                                 TextInputType.number,
//                                                                             style:
//                                                                                 TextStyle(color: API.textcolor, fontWeight: FontWeight.w400),
//                                                                             decoration: InputDecoration(
//                                                                                 filled: true,
//                                                                                 fillColor: const Color.fromRGBO(248, 248, 253, 1),
//                                                                                 enabledBorder: OutlineInputBorder(
//                                                                                   borderRadius: BorderRadius.circular(4.0),
//                                                                                   borderSide: BorderSide(
//                                                                                     color: API.bordercolor,
//                                                                                     width: 1.0,
//                                                                                   ),
//                                                                                 ),
//                                                                                 focusedBorder: OutlineInputBorder(
//                                                                                   borderRadius: BorderRadius.circular(4.0),
//                                                                                   borderSide: const BorderSide(
//                                                                                     color: Colors.green,
//                                                                                     width: 1.0,
//                                                                                   ),
//                                                                                 ),
//                                                                                 hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
//                                                                                 contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//                                                                                 // ignore: unnecessary_null_comparison
//                                                                                 hintText: 'Code',
//                                                                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     )
//                                                                   : SizedBox(),
//                                                               SizedBox(
//                                                                 height: 2,
//                                                               ),
//                                                               Divider(
//                                                                 color: API
//                                                                     .bordercolor,
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 2,
//                                                               ),
//                                                               Container(
//                                                                   height: MediaQuery.of(
//                                                                               context)
//                                                                           .size
//                                                                           .height /
//                                                                       7,
//                                                                   child:
//                                                                       Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         left:
//                                                                             10,
//                                                                         top: 5),
//                                                                     child:
//                                                                         Column(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .spaceAround,
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         Text(
//                                                                           "Grand Total",
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.black,
//                                                                               fontSize: 12,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                         Text(
//                                                                           double.parse(selectedreceipt!["grand_total"])
//                                                                               .toStringAsFixed(2),
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.black,
//                                                                               fontSize: 15,
//                                                                               fontWeight: FontWeight.w700,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               5,
//                                                                         ),
//                                                                         receivedamountcontroller.text.isEmpty
//                                                                             ? SizedBox()
//                                                                             : Column(
//                                                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                 children: [
//                                                                                   Text(
//                                                                                     "Balance",
//                                                                                     textAlign: TextAlign.start,
//                                                                                     style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
//                                                                                   ),
//                                                                                   Text(
//                                                                                     double.parse((double.parse(receivedamountcontroller.text) - double.parse(selectedreceipt!["grand_total"])).toString()).toStringAsFixed(2),
//                                                                                     textAlign: TextAlign.start,
//                                                                                     style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
//                                                                                   ),
//                                                                                 ],
//                                                                               )
//                                                                       ],
//                                                                     ),
//                                                                   ))
//                                                             ],
//                                                           ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                               // Column(
//                               //   children: [
//                               //     SizedBox(
//                               //       height: 10,
//                               //     ),
//                               //     Row(
//                               //       mainAxisAlignment:
//                               //           MainAxisAlignment.center,
//                               //       children: [
//                               //         Text(
//                               //           "No : ${selectedreceipt!["id"]}",
//                               //           textAlign: TextAlign.start,
//                               //           style: TextStyle(
//                               //               color: Colors.black,
//                               //               fontSize: 18,
//                               //               fontWeight: FontWeight.w600,
//                               //               fontFamily: 'Montserrat'),
//                               //         ),
//                               //       ],
//                               //     ),
//                               //     Divider(
//                               //       color: API.bordercolor,
//                               //     ),
//                               //     Row(
//                               //       children: [
//                               //         Padding(
//                               //           padding:
//                               //               const EdgeInsets.all(8.0),
//                               //           child: FaIcon(
//                               //             FontAwesomeIcons.businessTime,
//                               //             color: Colors.green,
//                               //             size: 20,
//                               //           ),
//                               //         ),
//                               //         Text(
//                               //           selectedreceipt!["customer_name"],
//                               //           style: TextStyle(
//                               //               color: Colors.black,
//                               //               fontSize: 14,
//                               //               fontWeight: FontWeight.w600,
//                               //               fontFamily: 'Montserrat'),
//                               //         ),
//                               //       ],
//                               //     ),
//                               //     Row(
//                               //       children: [
//                               //         Padding(
//                               //           padding:
//                               //               const EdgeInsets.all(8.0),
//                               //           child: FaIcon(
//                               //             FontAwesomeIcons.moneyBill,
//                               //             color: Colors.green,
//                               //             size: 20,
//                               //           ),
//                               //         ),
//                               //         Text(
//                               //           selectedreceipt!["amount"] +
//                               //               " AED",
//                               //           style: TextStyle(
//                               //               color: Colors.black,
//                               //               fontSize: 14,
//                               //               fontWeight: FontWeight.w600,
//                               //               fontFamily: 'Montserrat'),
//                               //         ),
//                               //       ],
//                               //     ),
//                               //     Container(
//                               //       height: 60,
//                               //       child: ListView.builder(
//                               //           itemCount:
//                               //               selectedreceipt!["payment"]
//                               //                   .length,
//                               //           itemBuilder: (context, cindex) {
//                               //             if (selectedreceipt!["payment"]
//                               //                     [cindex]["selected"] ==
//                               //                 0) {
//                               //               return SizedBox();
//                               //             } else {
//                               //               return Card(
//                               //                 color: Colors.green,
//                               //                 elevation: 20,
//                               //                 child: Container(
//                               //                   height: 40,
//                               //                   child: Center(
//                               //                     child: Text(
//                               //                       selectedreceipt![
//                               //                                   "payment"]
//                               //                               [
//                               //                               cindex]["type"]
//                               //                           .toString()
//                               //                           .toUpperCase(),
//                               //                       style: TextStyle(
//                               //                           color:
//                               //                               Colors.white,
//                               //                           fontSize: 14,
//                               //                           fontWeight:
//                               //                               FontWeight
//                               //                                   .w600,
//                               //                           fontFamily:
//                               //                               'Montserrat'),
//                               //                     ),
//                               //                   ),
//                               //                 ),
//                               //               );
//                               //             }
//                               //           }),
//                               //     ),
//                               //     SizedBox(
//                               //       height: 10,
//                               //     ),
//                               //     Divider(
//                               //       color: API.bordercolor,
//                               //     ),
//                               //     Card(
//                               //       color: Colors.amber,
//                               //       elevation: 20,
//                               //       child: Container(
//                               //         height: 40,
//                               //         child: Center(
//                               //           child: Text(
//                               //             "PRINT RECEIPT",
//                               //             style: TextStyle(
//                               //                 color: Colors.white,
//                               //                 fontSize: 14,
//                               //                 fontWeight: FontWeight.w600,
//                               //                 fontFamily: 'Montserrat'),
//                               //           ),
//                               //         ),
//                               //       ),
//                               //     )
//                               //   ],
//                               // ),
//                               ))
//                     ],
//                   ),
//                 ),
//               ])),
//     );
//   }
// }
