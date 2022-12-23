// import 'dart:ffi';
// import 'dart:typed_data';
// import 'package:image/image.dart' as im;

// import 'package:esc_pos_printer/esc_pos_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:route_transitions/route_transitions.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:windowspos/api/api.dart';
// import 'package:windowspos/cart/cart.dart';
// import 'package:windowspos/frontend/dashboard.dart';
// import 'package:windowspos/frontend/successpage.dart';
// import 'package:windowspos/models/customermodel.dart';
// import 'package:windowspos/models/itemmodel.dart';

// class HomePage extends StatefulWidget {
//   final String ipaddress;
//   final String token;
//   final Map<String, dynamic> userdetails;
//   const HomePage(
//       {Key? key,
//       required this.token,
//       required this.userdetails,
//       required this.ipaddress})
//       : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   TextEditingController receivedamountcontroller = TextEditingController();
//   TextEditingController authorizationcodecontroller = TextEditingController();
//   dynamic imagebytes;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//     Future.delayed(Duration(seconds: 0), () async {
//       final ByteData invoicedata = await rootBundle.load(
//         'assets/images/logo2.png',
//       );
//       final Uint8List logoimgBytes = invoicedata.buffer.asUint8List();
//       final dynamic logoimage = im.decodeImage(logoimgBytes);
//       setState(() {
//         selectedreceipttype = receipttype[0];
//         imagebytes = logoimage;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//   }

//   //variables
//   Map<String, dynamic> itemdetails = {};
//   Map<String, dynamic> customerdetails = {};
//   Map<String, dynamic> selectedunit = {};
//   List<dynamic> array_units = [];
//   bool loading = false;
//   bool mainloading = false;

//   List<dynamic> receipttype = [
//     {"type": "Select", "code": ""},
//     {"type": "Cash", "code": "CH"},
//     {"type": "Card", "code": "CA"},
//   ];

//   Map<String, dynamic> selectedreceipttype = {};

//   @override
//   Widget build(BuildContext context) {
//     return ScopedModelDescendant<CartModel>(builder: (context, child, model) {
//       return Scaffold(
//           backgroundColor: API.background,
//           body: mainloading
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.red,
//                     strokeWidth: 1,
//                   ),
//                 )
//               : SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.all(2),
//                     child: Container(
//                       height: MediaQuery.of(context).size.height,
//                       width: MediaQuery.of(context).size.width,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.all(Radius.circular(6)),
//                           border: Border.all(color: API.bordercolor)),
//                       child: Column(
//                         children: [
//                           Container(
//                             height: MediaQuery.of(context).size.height / 5.8,
//                             width: MediaQuery.of(context).size.width,
//                             // color: Colors.red,
//                             child: Row(
//                               children: [
//                                 customerdetails.isEmpty
//                                     ? Padding(
//                                         padding:
//                                             const EdgeInsets.only(left: 40),
//                                         child: SizedBox(
//                                           child: Container(
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width /
//                                                 1.8,
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceAround,
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       "Choose customer"
//                                                           .toUpperCase(),
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 10,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                           fontFamily:
//                                                               'Montserrat'),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Container(
//                                                   height: 48,
//                                                   width: MediaQuery.of(context)
//                                                           .size
//                                                           .width /
//                                                       2.5,
//                                                   child: TypeAheadField(
//                                                       textFieldConfiguration:
//                                                           TextFieldConfiguration(
//                                                         style: TextStyle(
//                                                             color:
//                                                                 API.textcolor,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w400),
//                                                         decoration:
//                                                             InputDecoration(
//                                                                 filled: true,
//                                                                 fillColor:
//                                                                     const Color.fromRGBO(
//                                                                         248,
//                                                                         248,
//                                                                         253,
//                                                                         1),
//                                                                 enabledBorder:
//                                                                     OutlineInputBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               4.0),
//                                                                   borderSide:
//                                                                       BorderSide(
//                                                                     color: API
//                                                                         .bordercolor,
//                                                                     width: 1.0,
//                                                                   ),
//                                                                 ),
//                                                                 focusedBorder:
//                                                                     OutlineInputBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               4.0),
//                                                                   borderSide:
//                                                                       const BorderSide(
//                                                                     color: Colors
//                                                                         .green,
//                                                                     width: 1.0,
//                                                                   ),
//                                                                 ),
//                                                                 hintStyle: const TextStyle(
//                                                                     fontFamily:
//                                                                         'Montserrat',
//                                                                     color: Color.fromRGBO(
//                                                                         181,
//                                                                         184,
//                                                                         203,
//                                                                         1),
//                                                                     fontWeight: FontWeight
//                                                                         .w500,
//                                                                     fontSize:
//                                                                         14),
//                                                                 contentPadding:
//                                                                     const EdgeInsets.fromLTRB(
//                                                                         10.0,
//                                                                         10.0,
//                                                                         10.0,
//                                                                         10.0),
//                                                                 // ignore: unnecessary_null_comparison
//                                                                 hintText:
//                                                                     'Enter Customer',
//                                                                 border: OutlineInputBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(4.0))),
//                                                       ),
//                                                       suggestionsCallback:
//                                                           (value) async {
//                                                         if (value == null) {
//                                                           return await API
//                                                               .getCustomerQueryList(
//                                                                   "",
//                                                                   widget.token);
//                                                         } else {
//                                                           return await API
//                                                               .getCustomerQueryList(
//                                                                   value,
//                                                                   widget.token);
//                                                         }
//                                                       },
//                                                       itemBuilder: (context,
//                                                           CustomerSchema?
//                                                               itemslist) {
//                                                         final listdata =
//                                                             itemslist;
//                                                         return ListTile(
//                                                           title: Text(
//                                                             "${listdata!.name.toUpperCase()} [ ${listdata.phone.toUpperCase()} ] ",
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             softWrap: false,
//                                                             maxLines: 1,
//                                                             style: TextStyle(
//                                                                 fontFamily:
//                                                                     'Montserrat',
//                                                                 color: API
//                                                                     .textcolor,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                                 fontSize: 14),
//                                                           ),
//                                                         );
//                                                       },
//                                                       onSuggestionSelected:
//                                                           (CustomerSchema?
//                                                               itemslist) {
//                                                         final data = {
//                                                           'id': itemslist!.id,
//                                                           'name':
//                                                               itemslist.name,
//                                                           'phone':
//                                                               itemslist.phone,
//                                                           "email":
//                                                               itemslist.email,
//                                                           "location": itemslist
//                                                               .location,
//                                                         };
//                                                         setState(() {
//                                                           customerdetails =
//                                                               data;
//                                                         });
//                                                         print(customerdetails);
//                                                       }),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : Container(
//                                         width:
//                                             MediaQuery.of(context).size.width /
//                                                 1.8,
//                                         // color: Colors.brown,
//                                         child: Column(
//                                           children: [
//                                             SizedBox(
//                                               height: 5,
//                                             ),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   customerdetails = {};
//                                                 });
//                                               },
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 2,
//                                                         horizontal: 7),
//                                                 child: Row(
//                                                   children: [
//                                                     Container(
//                                                       width: 40,
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                     .symmetric(
//                                                                 horizontal: 5),
//                                                         child: FaIcon(
//                                                           FontAwesomeIcons
//                                                               .businessTime,
//                                                           color: Colors.black,
//                                                           size: 18,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Expanded(
//                                                       child: Row(
//                                                         children: [
//                                                           Text(
//                                                             customerdetails[
//                                                                     "name"]
//                                                                 .toString()
//                                                                 .toUpperCase(),
//                                                             style: API
//                                                                 .textdetailstyle(),
//                                                           )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     FaIcon(
//                                                       FontAwesomeIcons.edit,
//                                                       color: Colors.green,
//                                                       size: 18,
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 2,
//                                                       horizontal: 7),
//                                               child: Row(
//                                                 children: [
//                                                   Container(
//                                                     width: 40,
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 5),
//                                                       child: FaIcon(
//                                                         FontAwesomeIcons
//                                                             .squarePhone,
//                                                         color: Colors.black,
//                                                         size: 18,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     child: Row(
//                                                       children: [
//                                                         Text(
//                                                           customerdetails[
//                                                                   "phone"]
//                                                               .toString()
//                                                               .toUpperCase(),
//                                                           style: API
//                                                               .textdetailstyle(),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 2,
//                                                       horizontal: 7),
//                                               child: Row(
//                                                 children: [
//                                                   Container(
//                                                     width: 40,
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 5),
//                                                       child: FaIcon(
//                                                         FontAwesomeIcons
//                                                             .locationDot,
//                                                         color: Colors.black,
//                                                         size: 18,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     child: Row(
//                                                       children: [
//                                                         Text(
//                                                           customerdetails[
//                                                                   "location"]
//                                                               .toString()
//                                                               .toUpperCase(),
//                                                           style: API
//                                                               .textdetailstyle(),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   // FaIcon(
//                                                   //   FontAwesomeIcons.edit,
//                                                   //   color: Colors.green,
//                                                   //   size: 18,
//                                                   // )
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 7, right: 7, top: 2),
//                                               child: Row(
//                                                 children: [
//                                                   Container(
//                                                     width: 40,
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 5),
//                                                       child: FaIcon(
//                                                         FontAwesomeIcons
//                                                             .envelope,
//                                                         color: Colors.black,
//                                                         size: 18,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     child: Row(
//                                                       children: [
//                                                         Text(
//                                                           customerdetails[
//                                                                   "email"]
//                                                               .toString()
//                                                               .toUpperCase(),
//                                                           style: API
//                                                               .textdetailstyle(),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                 SizedBox(
//                                   height:
//                                       MediaQuery.of(context).size.height / 6,
//                                   width: 2,
//                                   child: VerticalDivider(
//                                     color: API.bordercolor,
//                                   ),
//                                 ),
//                                 Expanded(
//                                     child: Container(
//                                   // color: Colors.blue,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 20),
//                                     child: Row(
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Container(
//                                               // color: Colors.red,
//                                               child: Image.asset(
//                                                 "assets/images/logo1.png",
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height /
//                                                     6,
//                                                 width: 70,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           width: 20,
//                                         ),
//                                         Expanded(
//                                             child: Container(
//                                           // color: Colors.yellow,
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     widget.userdetails[
//                                                             "company_name"]
//                                                         .toUpperCase(),
//                                                     style:
//                                                         API.textdetailstyle(),
//                                                   )
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     widget.userdetails[
//                                                             "billing_address"]
//                                                         .toString()
//                                                         .toUpperCase(),
//                                                     overflow:
//                                                         TextOverflow.visible,
//                                                     style:
//                                                         API.textdetailstyle(),
//                                                   )
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     widget.userdetails[
//                                                             "genral_phno"]
//                                                         .toString(),
//                                                     style:
//                                                         API.textdetailstyle(),
//                                                   )
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ))
//                                       ],
//                                     ),
//                                   ),
//                                 ))
//                               ],
//                             ),
//                           ),
//                           Container(
//                             height: 1,
//                             width: MediaQuery.of(context).size.width,
//                             color: API.bordercolor,
//                           ),
//                           Expanded(
//                               child: Row(
//                             children: [
//                               Expanded(
//                                   child: Column(
//                                 children: [
//                                   Expanded(
//                                       child: Container(
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           // height: MediaQuery.of(context)
//                                           //         .size
//                                           //         .height /
//                                           //     9,
//                                           height: 60,
//                                           width: double.maxFinite,
//                                           color: Colors.green,
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceAround,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         "Item Name"
//                                                             .toUpperCase(),
//                                                         textAlign:
//                                                             TextAlign.start,
//                                                         style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontFamily:
//                                                                 'Montserrat'),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   itemdetails.isNotEmpty
//                                                       ? Container(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               3.8,
//                                                           height: 44,
//                                                           decoration:
//                                                               BoxDecoration(
//                                                                   // border:
//                                                                   color:
//                                                                       const Color
//                                                                               .fromRGBO(
//                                                                           248,
//                                                                           248,
//                                                                           253,
//                                                                           1),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               4.0),
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .green,
//                                                                       width:
//                                                                           1.0)),
//                                                           child: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .fromLTRB(
//                                                                     20.0,
//                                                                     5.0,
//                                                                     20.0,
//                                                                     5.0),
//                                                             child: Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .spaceBetween,
//                                                               children: [
//                                                                 Container(
//                                                                   width: MediaQuery.of(
//                                                                               context)
//                                                                           .size
//                                                                           .width /
//                                                                       4.7,
//                                                                   child: Text(
//                                                                     itemdetails['part_number']
//                                                                             .toString() +
//                                                                         " [ " +
//                                                                         itemdetails[
//                                                                             "description"] +
//                                                                         " ] "
//                                                                             .toString()
//                                                                             .toUpperCase(),
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     style: TextStyle(
//                                                                         fontFamily:
//                                                                             'Montserrat',
//                                                                         color: API
//                                                                             .textcolor,
//                                                                         fontWeight:
//                                                                             FontWeight
//                                                                                 .w400,
//                                                                         fontSize:
//                                                                             14),
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         )
//                                                       : Container(
//                                                           height: 44,
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               3,
//                                                           child: TypeAheadField(
//                                                               textFieldConfiguration:
//                                                                   TextFieldConfiguration(
//                                                                 style: TextStyle(
//                                                                     color: API
//                                                                         .textcolor,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w400),
//                                                                 decoration:
//                                                                     InputDecoration(
//                                                                         filled:
//                                                                             true,
//                                                                         fillColor: const Color.fromRGBO(
//                                                                             248,
//                                                                             248,
//                                                                             253,
//                                                                             1),
//                                                                         enabledBorder:
//                                                                             OutlineInputBorder(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(4.0),
//                                                                           borderSide:
//                                                                               BorderSide(
//                                                                             color:
//                                                                                 API.bordercolor,
//                                                                             width:
//                                                                                 1.0,
//                                                                           ),
//                                                                         ),
//                                                                         focusedBorder:
//                                                                             OutlineInputBorder(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(4.0),
//                                                                           borderSide:
//                                                                               const BorderSide(
//                                                                             color:
//                                                                                 Colors.green,
//                                                                             width:
//                                                                                 1.0,
//                                                                           ),
//                                                                         ),
//                                                                         hintStyle: const TextStyle(
//                                                                             fontFamily:
//                                                                                 'Montserrat',
//                                                                             color: Color.fromRGBO(
//                                                                                 181,
//                                                                                 184,
//                                                                                 203,
//                                                                                 1),
//                                                                             fontWeight: FontWeight
//                                                                                 .w500,
//                                                                             fontSize:
//                                                                                 14),
//                                                                         contentPadding: const EdgeInsets.fromLTRB(
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0),
//                                                                         // ignore: unnecessary_null_comparison
//                                                                         hintText:
//                                                                             'Enter Item Name',
//                                                                         border: OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(4.0))),
//                                                               ),
//                                                               suggestionsCallback:
//                                                                   (value) async {
//                                                                 if (value ==
//                                                                     null) {
//                                                                   return await API
//                                                                       .getItemsQueryList(
//                                                                           "",
//                                                                           "",
//                                                                           widget
//                                                                               .token);
//                                                                 } else {
//                                                                   return await API
//                                                                       .getItemsQueryList(
//                                                                           value,
//                                                                           "",
//                                                                           widget
//                                                                               .token);
//                                                                 }
//                                                               },
//                                                               itemBuilder: (context,
//                                                                   ItemSchema?
//                                                                       itemslist) {
//                                                                 final listdata =
//                                                                     itemslist;
//                                                                 return ListTile(
//                                                                   title: Text(
//                                                                     "${listdata!.partnumber.toUpperCase()} [ ${listdata.description.toUpperCase()} ] ",
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     softWrap:
//                                                                         false,
//                                                                     maxLines: 1,
//                                                                     style: TextStyle(
//                                                                         fontFamily:
//                                                                             'Montserrat',
//                                                                         color: API
//                                                                             .textcolor,
//                                                                         fontWeight:
//                                                                             FontWeight
//                                                                                 .w500,
//                                                                         fontSize:
//                                                                             14),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                               onSuggestionSelected:
//                                                                   (ItemSchema?
//                                                                       itemslist) {
//                                                                 final data = {
//                                                                   'id':
//                                                                       itemslist!
//                                                                           .id,
//                                                                   'part_number':
//                                                                       itemslist
//                                                                           .partnumber,
//                                                                   'description':
//                                                                       itemslist
//                                                                           .description,
//                                                                   "brand_id":
//                                                                       itemslist
//                                                                           .brandid,
//                                                                   "brand_name":
//                                                                       itemslist
//                                                                           .brandname,
//                                                                   "rate":
//                                                                       itemslist
//                                                                           .rate,
//                                                                   "quantity":
//                                                                       itemslist
//                                                                           .quantity,
//                                                                   "warehouse_id":
//                                                                       itemslist
//                                                                           .warehouseid,
//                                                                   "unit_name":
//                                                                       itemslist
//                                                                           .unit_name,
//                                                                   "unit_id":
//                                                                       itemslist
//                                                                           .unit_id,
//                                                                   "arr_units":
//                                                                       itemslist
//                                                                           .arr_units,
//                                                                   "tax_code":
//                                                                       itemslist
//                                                                           .tax_code,
//                                                                   "discount":
//                                                                       itemslist
//                                                                           .discount
//                                                                 };
//                                                                 setState(() {
//                                                                   itemdetails =
//                                                                       data;
//                                                                   selectedunit =
//                                                                       itemslist
//                                                                           .arr_units[0];
//                                                                   array_units =
//                                                                       itemslist
//                                                                           .arr_units;
//                                                                 });
//                                                                 print(
//                                                                     itemdetails);
//                                                                 print(
//                                                                     selectedunit);
//                                                               }),
//                                                         ),
//                                                 ],
//                                               ),
//                                               itemdetails.isNotEmpty
//                                                   ? Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceAround,
//                                                       children: [
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               "Rate"
//                                                                   .toUpperCase(),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .start,
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Container(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               11,
//                                                           height: 44,
//                                                           // color: Colors.red,
//                                                           child: TextFormField(
//                                                             keyboardType:
//                                                                 TextInputType
//                                                                     .number,
//                                                             initialValue:
//                                                                 itemdetails[
//                                                                     "rate"],
//                                                             style: TextStyle(
//                                                                 color: API
//                                                                     .textcolor,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400),
//                                                             decoration:
//                                                                 InputDecoration(
//                                                                     filled:
//                                                                         true,
//                                                                     fillColor:
//                                                                         const Color.fromRGBO(
//                                                                             248,
//                                                                             248,
//                                                                             253,
//                                                                             1),
//                                                                     enabledBorder:
//                                                                         OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4.0),
//                                                                       borderSide:
//                                                                           BorderSide(
//                                                                         color: API
//                                                                             .bordercolor,
//                                                                         width:
//                                                                             1.0,
//                                                                       ),
//                                                                     ),
//                                                                     focusedBorder:
//                                                                         OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4.0),
//                                                                       borderSide:
//                                                                           const BorderSide(
//                                                                         color: Colors
//                                                                             .green,
//                                                                         width:
//                                                                             1.0,
//                                                                       ),
//                                                                     ),
//                                                                     hintStyle: const TextStyle(
//                                                                         fontFamily:
//                                                                             'Montserrat',
//                                                                         color: Color.fromRGBO(
//                                                                             181,
//                                                                             184,
//                                                                             203,
//                                                                             1),
//                                                                         fontWeight: FontWeight
//                                                                             .w500,
//                                                                         fontSize:
//                                                                             14),
//                                                                     contentPadding:
//                                                                         const EdgeInsets.fromLTRB(
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0),
//                                                                     // ignore: unnecessary_null_comparison
//                                                                     hintText:
//                                                                         'Rate',
//                                                                     border: OutlineInputBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(4.0))),
//                                                             onChanged: (val) {
//                                                               setState(() {
//                                                                 itemdetails[
//                                                                         "rate"] =
//                                                                     val;
//                                                               });
//                                                               print(
//                                                                   itemdetails);
//                                                             },
//                                                           ),
//                                                         )
//                                                       ],
//                                                     )
//                                                   : SizedBox(),
//                                               itemdetails.isNotEmpty
//                                                   ? Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceAround,
//                                                       children: [
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               "Quantity"
//                                                                   .toUpperCase(),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .start,
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Container(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               11,
//                                                           height: 44,
//                                                           // color: Colors.red,
//                                                           child: TextFormField(
//                                                             initialValue:
//                                                                 itemdetails[
//                                                                     "quantity"],
//                                                             keyboardType:
//                                                                 TextInputType
//                                                                     .number,
//                                                             style: TextStyle(
//                                                                 color: API
//                                                                     .textcolor,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400),
//                                                             decoration:
//                                                                 InputDecoration(
//                                                                     filled:
//                                                                         true,
//                                                                     fillColor:
//                                                                         const Color.fromRGBO(
//                                                                             248,
//                                                                             248,
//                                                                             253,
//                                                                             1),
//                                                                     enabledBorder:
//                                                                         OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4.0),
//                                                                       borderSide:
//                                                                           BorderSide(
//                                                                         color: API
//                                                                             .bordercolor,
//                                                                         width:
//                                                                             1.0,
//                                                                       ),
//                                                                     ),
//                                                                     focusedBorder:
//                                                                         OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4.0),
//                                                                       borderSide:
//                                                                           const BorderSide(
//                                                                         color: Colors
//                                                                             .green,
//                                                                         width:
//                                                                             1.0,
//                                                                       ),
//                                                                     ),
//                                                                     hintStyle: const TextStyle(
//                                                                         fontFamily:
//                                                                             'Montserrat',
//                                                                         color: Color.fromRGBO(
//                                                                             181,
//                                                                             184,
//                                                                             203,
//                                                                             1),
//                                                                         fontWeight: FontWeight
//                                                                             .w500,
//                                                                         fontSize:
//                                                                             14),
//                                                                     contentPadding:
//                                                                         const EdgeInsets.fromLTRB(
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0),
//                                                                     // ignore: unnecessary_null_comparison
//                                                                     hintText:
//                                                                         'QTY',
//                                                                     border: OutlineInputBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(4.0))),
//                                                             onChanged: (val) {
//                                                               setState(() {
//                                                                 itemdetails[
//                                                                         "quantity"] =
//                                                                     val;
//                                                               });
//                                                               print(
//                                                                   itemdetails);
//                                                             },
//                                                           ),
//                                                         )
//                                                       ],
//                                                     )
//                                                   : SizedBox(),
//                                               itemdetails.isNotEmpty
//                                                   ? Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceAround,
//                                                       children: [
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               "Unit"
//                                                                   .toUpperCase(),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .start,
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 10,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Container(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               11,
//                                                           height: 44,
//                                                           child: InputDecorator(
//                                                             decoration:
//                                                                 InputDecoration(
//                                                                     filled:
//                                                                         true,
//                                                                     fillColor:
//                                                                         const Color.fromRGBO(
//                                                                             248,
//                                                                             248,
//                                                                             253,
//                                                                             1),
//                                                                     enabledBorder:
//                                                                         OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4.0),
//                                                                       borderSide:
//                                                                           BorderSide(
//                                                                         color: API
//                                                                             .bordercolor,
//                                                                         width:
//                                                                             1.0,
//                                                                       ),
//                                                                     ),
//                                                                     focusedBorder:
//                                                                         OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4.0),
//                                                                       borderSide:
//                                                                           const BorderSide(
//                                                                         color: Colors
//                                                                             .green,
//                                                                         width:
//                                                                             1.0,
//                                                                       ),
//                                                                     ),
//                                                                     hintStyle: const TextStyle(
//                                                                         fontFamily:
//                                                                             'Montserrat',
//                                                                         color: Color.fromRGBO(
//                                                                             181,
//                                                                             184,
//                                                                             203,
//                                                                             1),
//                                                                         fontWeight: FontWeight
//                                                                             .w500,
//                                                                         fontSize:
//                                                                             14),
//                                                                     contentPadding:
//                                                                         const EdgeInsets.fromLTRB(
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0,
//                                                                             10.0),
//                                                                     // ignore: unnecessary_null_comparison
//                                                                     hintText:
//                                                                         'Unit',
//                                                                     border: OutlineInputBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(4.0))),
//                                                             child:
//                                                                 DropdownButtonHideUnderline(
//                                                               child:
//                                                                   DropdownButton<
//                                                                       dynamic>(
//                                                                 isExpanded:
//                                                                     true,
//                                                                 dropdownColor:
//                                                                     Colors
//                                                                         .white,
//                                                                 hint:
//                                                                     const Text(
//                                                                   'Choose Unit',
//                                                                   style: TextStyle(
//                                                                       color: Color.fromRGBO(
//                                                                           135,
//                                                                           141,
//                                                                           186,
//                                                                           1),
//                                                                       fontFamily:
//                                                                           'Montserrat',
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600,
//                                                                       fontSize:
//                                                                           14),
//                                                                 ),
//                                                                 value:
//                                                                     selectedunit,
//                                                                 isDense: true,
//                                                                 onChanged:
//                                                                     (data) async {
//                                                                   setState(() {
//                                                                     selectedunit =
//                                                                         data;
//                                                                   });
//                                                                 },
//                                                                 items: array_units
//                                                                     .map(
//                                                                         (value) {
//                                                                   return DropdownMenuItem<
//                                                                           dynamic>(
//                                                                       value:
//                                                                           value,
//                                                                       child:
//                                                                           Container(
//                                                                         decoration:
//                                                                             BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
//                                                                         height:
//                                                                             20.0,
//                                                                         padding: const EdgeInsets.fromLTRB(
//                                                                             10.0,
//                                                                             2.0,
//                                                                             10.0,
//                                                                             0.0),
//                                                                         child:
//                                                                             Container(
//                                                                           child:
//                                                                               Text(
//                                                                             value['unit_name'].toString().toUpperCase(),
//                                                                             style: TextStyle(
//                                                                                 fontFamily: 'Montserrat',
//                                                                                 color: API.textcolor,
//                                                                                 fontWeight: FontWeight.w500,
//                                                                                 fontSize: 14),
//                                                                           ),
//                                                                         ),
//                                                                       ));
//                                                                 }).toList(),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     )
//                                                   : SizedBox(),
//                                               itemdetails.isNotEmpty
//                                                   ? Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceAround,
//                                                       children: [
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 "Discount"
//                                                                     .toUpperCase(),
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .white,
//                                                                     fontSize:
//                                                                         10,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600,
//                                                                     fontFamily:
//                                                                         'Montserrat'),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           Container(
//                                                             width: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width /
//                                                                 11,
//                                                             height: 44,
//                                                             // color: Colors.red,
//                                                             child:
//                                                                 TextFormField(
//                                                               initialValue:
//                                                                   itemdetails[
//                                                                       "discount"],
//                                                               keyboardType:
//                                                                   TextInputType
//                                                                       .number,
//                                                               style: TextStyle(
//                                                                   color: API
//                                                                       .textcolor,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w400),
//                                                               decoration:
//                                                                   InputDecoration(
//                                                                       filled:
//                                                                           true,
//                                                                       fillColor: const Color.fromRGBO(
//                                                                           248,
//                                                                           248,
//                                                                           253,
//                                                                           1),
//                                                                       enabledBorder:
//                                                                           OutlineInputBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(4.0),
//                                                                         borderSide:
//                                                                             BorderSide(
//                                                                           color:
//                                                                               API.bordercolor,
//                                                                           width:
//                                                                               1.0,
//                                                                         ),
//                                                                       ),
//                                                                       focusedBorder:
//                                                                           OutlineInputBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(4.0),
//                                                                         borderSide:
//                                                                             const BorderSide(
//                                                                           color:
//                                                                               Colors.green,
//                                                                           width:
//                                                                               1.0,
//                                                                         ),
//                                                                       ),
//                                                                       hintStyle: const TextStyle(
//                                                                           fontFamily:
//                                                                               'Montserrat',
//                                                                           color: Color.fromRGBO(
//                                                                               181,
//                                                                               184,
//                                                                               203,
//                                                                               1),
//                                                                           fontWeight: FontWeight
//                                                                               .w500,
//                                                                           fontSize:
//                                                                               14),
//                                                                       contentPadding: const EdgeInsets.fromLTRB(
//                                                                           10.0,
//                                                                           10.0,
//                                                                           10.0,
//                                                                           10.0),
//                                                                       // ignore: unnecessary_null_comparison
//                                                                       hintText:
//                                                                           'Discount',
//                                                                       border: OutlineInputBorder(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(4.0))),
//                                                               onChanged: (val) {
//                                                                 setState(() {
//                                                                   itemdetails[
//                                                                           "discount"] =
//                                                                       val;
//                                                                 });
//                                                               },
//                                                             ),
//                                                           )
//                                                         ])
//                                                   : SizedBox(),
//                                               itemdetails.isNotEmpty
//                                                   ? IconButton(
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           itemdetails = {};
//                                                         });
//                                                       },
//                                                       icon: FaIcon(
//                                                         FontAwesomeIcons.trash,
//                                                         size: 20,
//                                                         color: Colors.red,
//                                                       ))
//                                                   : SizedBox(),
//                                               itemdetails.isNotEmpty
//                                                   ? IconButton(
//                                                       onPressed: () {
//                                                         if (model.checkItems(
//                                                             itemdetails["id"],
//                                                             model.cart)) {
//                                                           Get.snackbar("Failed",
//                                                               "Product already added",
//                                                               backgroundColor:
//                                                                   Colors.red,
//                                                               colorText:
//                                                                   Colors.white);
//                                                         } else {
//                                                           model.addProduct(ItemSchema(
//                                                               id: itemdetails[
//                                                                   "id"],
//                                                               partnumber: itemdetails[
//                                                                   "part_number"],
//                                                               description: itemdetails[
//                                                                   "description"],
//                                                               brandid: itemdetails[
//                                                                   "brand_id"],
//                                                               brandname: itemdetails[
//                                                                   "brand_name"],
//                                                               rate: itemdetails[
//                                                                   "rate"],
//                                                               quantity: itemdetails[
//                                                                   "quantity"],
//                                                               warehouseid:
//                                                                   itemdetails[
//                                                                       "warehouse_id"],
//                                                               unit_name:
//                                                                   selectedunit[
//                                                                           "unit_name"]
//                                                                       .toString(),
//                                                               unit_id:
//                                                                   selectedunit["id"]
//                                                                       .toString(),
//                                                               arr_units:
//                                                                   itemdetails[
//                                                                       "arr_units"],
//                                                               tax_code:
//                                                                   itemdetails[
//                                                                       "tax_code"],
//                                                               discount: itemdetails[
//                                                                   "discount"]));
//                                                           model
//                                                               .calculateTotalRate();
//                                                           setState(() {
//                                                             itemdetails = {};
//                                                           });
//                                                         }
//                                                       },
//                                                       icon: FaIcon(
//                                                         FontAwesomeIcons
//                                                             .checkCircle,
//                                                         size: 20,
//                                                         color: Colors.white,
//                                                       ))
//                                                   : SizedBox()
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                             child: Container(
//                                           // color: Colors.yellow,
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 height: 40,
//                                                 color: Colors.yellow,
//                                                 child: Row(
//                                                   children: [
//                                                     Container(
//                                                       width: 25,
//                                                     ),
//                                                     Container(
//                                                       width:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width /
//                                                               5,
//                                                       color: Colors.red,
//                                                       child: Text(
//                                                         "Item Code",
//                                                         textAlign:
//                                                             TextAlign.start,
//                                                         style: TextStyle(
//                                                             color: Colors.black,
//                                                             fontSize: 12,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontFamily:
//                                                                 'Montserrat'),
//                                                       ),
//                                                     ),
//                                                     Container(
//                                                       width:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width /
//                                                               1.8,
//                                                       color: Colors.blue,
//                                                       child: Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceEvenly,
//                                                         children: [
//                                                           Row(
//                                                             children: [
//                                                               Text(
//                                                                 "Brand",
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
//                                                             ],
//                                                           ),
//                                                           Text(
//                                                             "Rate",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                           Text(
//                                                             "Qty",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                           Text(
//                                                             "Unit",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                           Text(
//                                                             "Dis",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                           Text(
//                                                             "VAT",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                           Text(
//                                                             "Total",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: ListView.builder(
//                                                     itemCount:
//                                                         model.cart.length,
//                                                     itemBuilder:
//                                                         (context, index) {
//                                                       return ListTile(
//                                                         leading: Container(
//                                                           width: 30,
//                                                           height: 40,
//                                                           child: Center(
//                                                             child: Text(
//                                                               (index + 1)
//                                                                   .toString(),
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize: 14,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         title: Text(
//                                                           model.cart[index]
//                                                               .partnumber
//                                                               .toUpperCase(),
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           style: const TextStyle(
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 12,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500,
//                                                               fontFamily:
//                                                                   'Montserrat'),
//                                                         ),
//                                                         subtitle: Text(
//                                                           model.cart[index]
//                                                               .description,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           style: const TextStyle(
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 11,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w400,
//                                                               fontFamily:
//                                                                   'Montserrat'),
//                                                         ),
//                                                         trailing: Container(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               1.8,
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceAround,
//                                                             children: [
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Brand",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           model
//                                                                               .cart[index]
//                                                                               .brandname,
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Rate",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           model
//                                                                               .cart[index]
//                                                                               .rate,
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Quantity",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           model
//                                                                               .cart[index]
//                                                                               .quantity,
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Unit",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           model
//                                                                               .cart[index]
//                                                                               .unit_name
//                                                                               .toString(),
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Discount",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           (double.parse(model.cart[index].discount.toString()) * double.parse(model.cart[index].quantity.toString()))
//                                                                               .toStringAsFixed(2),
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Vat",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           double.parse(((double.parse(((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate)) - (double.parse(model.cart[index].quantity) * double.parse(model.cart[index].discount))).toString()) * (double.parse(model.cart[index].tax_code))) / 100).toString())
//                                                                               .toStringAsFixed(2)

//                                                                           // ((double.parse((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate)).toString()) * double.parse(model.cart[index].tax_code)) /
//                                                                           //         100)
//                                                                           //     .toStringAsFixed(
//                                                                           //         2),
//                                                                           ,
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   // Text(
//                                                                   //   "Total",
//                                                                   //   textAlign:
//                                                                   //       TextAlign
//                                                                   //           .start,
//                                                                   //   style: TextStyle(
//                                                                   //       color: Colors
//                                                                   //           .black,
//                                                                   //       fontSize:
//                                                                   //           12,
//                                                                   //       fontWeight:
//                                                                   //           FontWeight
//                                                                   //               .w600,
//                                                                   //       fontFamily:
//                                                                   //           'Montserrat'),
//                                                                   // ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .symmetric(
//                                                                         vertical:
//                                                                             5),
//                                                                     child: Row(
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .center,
//                                                                       children: [
//                                                                         Text(
//                                                                           // double.parse((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate))
//                                                                           //         .toString())
//                                                                           //     .toStringAsFixed(
//                                                                           //         2),
//                                                                           double.parse(((double.parse(((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate)) - (double.parse(model.cart[index].quantity) * double.parse(model.cart[index].discount))).toString())) + double.parse(((double.parse(((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate)) - (double.parse(model.cart[index].quantity) * double.parse(model.cart[index].discount))).toString()) * (double.parse(model.cart[index].tax_code))) / 100).toString())).toString())
//                                                                               .toStringAsFixed(2),
//                                                                           textAlign:
//                                                                               TextAlign.start,
//                                                                           style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontSize: 13,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontFamily: 'Montserrat'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 ],
//                                                               ),
//                                                               // Column(
//                                                               //   mainAxisAlignment:
//                                                               //       MainAxisAlignment
//                                                               //           .center,
//                                                               //   crossAxisAlignment:
//                                                               //       CrossAxisAlignment
//                                                               //           .start,
//                                                               //   children: [
//                                                               //     Text(
//                                                               //       "Total",
//                                                               //       textAlign:
//                                                               //           TextAlign
//                                                               //               .start,
//                                                               //       style: TextStyle(
//                                                               //           color: Colors
//                                                               //               .black,
//                                                               //           fontSize: 12,
//                                                               //           fontWeight:
//                                                               //               FontWeight
//                                                               //                   .w600,
//                                                               //           fontFamily:
//                                                               //               'Montserrat'),
//                                                               //     ),
//                                                               //     Padding(
//                                                               //       padding:
//                                                               //           const EdgeInsets
//                                                               //                   .symmetric(
//                                                               //               vertical:
//                                                               //                   5),
//                                                               //       child: Row(
//                                                               //         mainAxisAlignment:
//                                                               //             MainAxisAlignment
//                                                               //                 .center,
//                                                               //         children: [
//                                                               //           Text(
//                                                               //             ((((double.parse((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate)).toString()) * double.parse(model.cart[index].tax_code)) / 100) +
//                                                               //                         double.parse((double.parse(model.cart[index].quantity) * double.parse(model.cart[index].rate)).toString())) +
//                                                               //                     double.parse(model.cart[index].discount))
//                                                               //                 .toStringAsFixed(2),
//                                                               //             textAlign:
//                                                               //                 TextAlign
//                                                               //                     .start,
//                                                               //             style: TextStyle(
//                                                               //                 color: Colors
//                                                               //                     .green,
//                                                               //                 fontSize:
//                                                               //                     13,
//                                                               //                 fontWeight:
//                                                               //                     FontWeight
//                                                               //                         .w600,
//                                                               //                 fontFamily:
//                                                               //                     'Montserrat'),
//                                                               //           ),
//                                                               //         ],
//                                                               //       ),
//                                                               //     )
//                                                               //   ],
//                                                               // ),
//                                                               IconButton(
//                                                                   onPressed:
//                                                                       () {
//                                                                     model.removeProduct(model
//                                                                         .cart[
//                                                                             index]
//                                                                         .id);
//                                                                     model
//                                                                         .calculateTotalRate();
//                                                                   },
//                                                                   icon: Icon(
//                                                                       Icons
//                                                                           .delete,
//                                                                       color: Colors
//                                                                           .red))
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }),
//                                               ),
//                                             ],
//                                           ),
//                                         ))
//                                       ],
//                                     ),
//                                   )),
//                                   Container(
//                                     height: 1,
//                                     color: API.bordercolor,
//                                   ),
//                                   Container(
//                                     height:
//                                         MediaQuery.of(context).size.height / 8,
//                                     width: MediaQuery.of(context).size.width,
//                                     // color: Colors.yellow,
//                                     child: loading
//                                         ? Center(
//                                             child: CircularProgressIndicator(
//                                               color: Colors.red,
//                                               strokeWidth: 1,
//                                             ),
//                                           )
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.end,
//                                             children: [
//                                               Column(
//                                                 children: [
//                                                   RawMaterialButton(
//                                                     onPressed: () async {
//                                                       if (customerdetails
//                                                           .isEmpty) {
//                                                         Get.snackbar(
//                                                             "Failed",
//                                                             "Please select customer"
//                                                                 .toString(),
//                                                             backgroundColor:
//                                                                 Colors.red,
//                                                             colorText:
//                                                                 Colors.white);
//                                                       } else {
//                                                         if (receivedamountcontroller
//                                                                     .text ==
//                                                                 "" &&
//                                                             selectedreceipttype[
//                                                                     "code"] ==
//                                                                 "") {
//                                                           setState(() {
//                                                             mainloading = true;
//                                                           });
//                                                           final dynamic
//                                                               calculationresponse =
//                                                               await API
//                                                                   .convertData(
//                                                                       model
//                                                                           .cart);
//                                                           final dynamic saveinvoiceresponse = await API.saveInvoiceAPI(
//                                                               customerdetails[
//                                                                   "id"],
//                                                               calculationresponse[
//                                                                   "items"],
//                                                               selectedreceipttype[
//                                                                   "code"],
//                                                               receivedamountcontroller
//                                                                       .text
//                                                                       .isEmpty
//                                                                   ? ""
//                                                                   : receivedamountcontroller
//                                                                       .text,
//                                                               authorizationcodecontroller
//                                                                       .text
//                                                                       .isEmpty
//                                                                   ? ""
//                                                                   : authorizationcodecontroller
//                                                                       .text,
//                                                               widget.token);
//                                                           if (saveinvoiceresponse[
//                                                                   "status"] ==
//                                                               "success") {
//                                                             model.removeAll();
//                                                             selectedreceipttype =
//                                                                 {};
//                                                             receivedamountcontroller
//                                                                 .text = "";
//                                                             authorizationcodecontroller
//                                                                 .text = "";
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
//                                                                 widget
//                                                                     .ipaddress,
//                                                                 printer,
//                                                                 saveinvoiceresponse[
//                                                                     "items"],
//                                                                 saveinvoiceresponse[
//                                                                         "total_amount"]
//                                                                     .toString(),
//                                                                 saveinvoiceresponse[
//                                                                         "total_tax_amount"]
//                                                                     .toString(),
//                                                                 imagebytes,
//                                                                 saveinvoiceresponse[
//                                                                     "invoice_id"],
//                                                                 saveinvoiceresponse[
//                                                                     "customer_name"],
//                                                                 saveinvoiceresponse[
//                                                                     "invoice_date"],
//                                                                 saveinvoiceresponse[
//                                                                     "warehouse_name"],
//                                                                 saveinvoiceresponse[
//                                                                         "grand_total"]
//                                                                     .toString(),
//                                                                 widget.userdetails[
//                                                                     "company_name"],
//                                                                 widget.userdetails[
//                                                                     "billing_address"],
//                                                                 widget.userdetails[
//                                                                     "genral_phno"],
//                                                                 saveinvoiceresponse[
//                                                                     "customer_phone"],
//                                                                 saveinvoiceresponse[
//                                                                     "sales_man"],
//                                                                 saveinvoiceresponse[
//                                                                     "receipt_type"],
//                                                                 saveinvoiceresponse[
//                                                                     "received_amount"]);
//                                                             printer
//                                                                 .disconnect();
//                                                             setState(() {
//                                                               loading = false;
//                                                             });
//                                                             pushWidgetWhileRemove(
//                                                                 newPage:
//                                                                     SuccessPage(
//                                                                         screen:
//                                                                             dashboard()),
//                                                                 context:
//                                                                     context);
//                                                           } else {
//                                                             setState(() {
//                                                               mainloading =
//                                                                   false;
//                                                             });
//                                                             Get.snackbar(
//                                                                 "Failed",
//                                                                 saveinvoiceresponse[
//                                                                         "msg"]
//                                                                     .toString(),
//                                                                 backgroundColor:
//                                                                     Colors.red,
//                                                                 colorText:
//                                                                     Colors
//                                                                         .white);
//                                                           }
//                                                         } else {
//                                                           print(
//                                                               "The grand total value inside is else");
//                                                           print((double.parse((model
//                                                                           .totalPrice)
//                                                                       .toString()) +
//                                                                   double.parse((model
//                                                                           .totalvat)
//                                                                       .toString()))
//                                                               .toStringAsFixed(
//                                                                   2));
//                                                           print(
//                                                               receivedamountcontroller
//                                                                   .text);
//                                                           if (receivedamountcontroller
//                                                                   .text ==
//                                                               "") {
//                                                             Get.snackbar(
//                                                                 "Failed",
//                                                                 "Please enter received amount"
//                                                                     .toString(),
//                                                                 backgroundColor:
//                                                                     Colors.red,
//                                                                 colorText:
//                                                                     Colors
//                                                                         .white);
//                                                           } else {
//                                                             if (double.parse(
//                                                                     receivedamountcontroller
//                                                                         .text) >=
//                                                                 double.parse((double.parse((model.totalPrice)
//                                                                             .toString()) +
//                                                                         double.parse((model.totalvat)
//                                                                             .toString()))
//                                                                     .toStringAsFixed(
//                                                                         2))) {
//                                                               setState(() {
//                                                                 mainloading =
//                                                                     true;
//                                                               });
//                                                               final dynamic
//                                                                   calculationresponse =
//                                                                   await API
//                                                                       .convertData(
//                                                                           model
//                                                                               .cart);
//                                                               final dynamic saveinvoiceresponse = await API.saveInvoiceAPI(
//                                                                   customerdetails[
//                                                                       "id"],
//                                                                   calculationresponse[
//                                                                       "items"],
//                                                                   selectedreceipttype[
//                                                                       "code"],
//                                                                   receivedamountcontroller
//                                                                           .text
//                                                                           .isEmpty
//                                                                       ? ""
//                                                                       : (double.parse((model.totalPrice).toString()) +
//                                                                               double.parse((model.totalvat)
//                                                                                   .toString()))
//                                                                           .toStringAsFixed(
//                                                                               2),
//                                                                   authorizationcodecontroller
//                                                                           .text
//                                                                           .isEmpty
//                                                                       ? ""
//                                                                       : authorizationcodecontroller
//                                                                           .text,
//                                                                   widget.token);
//                                                               if (saveinvoiceresponse[
//                                                                       "status"] ==
//                                                                   "success") {
//                                                                 model
//                                                                     .removeAll();
//                                                                 selectedreceipttype =
//                                                                     {};
//                                                                 receivedamountcontroller
//                                                                     .text = "";
//                                                                 authorizationcodecontroller
//                                                                     .text = "";
//                                                                 const PaperSize
//                                                                     paper =
//                                                                     PaperSize
//                                                                         .mm80;
//                                                                 final profile =
//                                                                     await CapabilityProfile
//                                                                         .load();
//                                                                 final printer =
//                                                                     NetworkPrinter(
//                                                                         paper,
//                                                                         profile);
//                                                                 API.printInvoice(
//                                                                     widget
//                                                                         .ipaddress,
//                                                                     printer,
//                                                                     saveinvoiceresponse[
//                                                                         "items"],
//                                                                     saveinvoiceresponse[
//                                                                             "total_amount"]
//                                                                         .toString(),
//                                                                     saveinvoiceresponse[
//                                                                             "total_tax_amount"]
//                                                                         .toString(),
//                                                                     imagebytes,
//                                                                     saveinvoiceresponse[
//                                                                         "invoice_id"],
//                                                                     saveinvoiceresponse[
//                                                                         "customer_name"],
//                                                                     saveinvoiceresponse[
//                                                                         "invoice_date"],
//                                                                     saveinvoiceresponse[
//                                                                         "warehouse_name"],
//                                                                     saveinvoiceresponse[
//                                                                             "grand_total"]
//                                                                         .toString(),
//                                                                     widget.userdetails[
//                                                                         "company_name"],
//                                                                     widget.userdetails[
//                                                                         "billing_address"],
//                                                                     widget.userdetails[
//                                                                         "genral_phno"],
//                                                                     saveinvoiceresponse[
//                                                                         "customer_phone"],
//                                                                     saveinvoiceresponse[
//                                                                         "sales_man"],
//                                                                     saveinvoiceresponse[
//                                                                         "receipt_type"],
//                                                                     saveinvoiceresponse[
//                                                                         "received_amount"]);
//                                                                 printer
//                                                                     .disconnect();
//                                                                 setState(() {
//                                                                   loading =
//                                                                       false;
//                                                                 });

//                                                                 pushWidgetWhileRemove(
//                                                                     newPage: SuccessPage(
//                                                                         screen:
//                                                                             dashboard()),
//                                                                     context:
//                                                                         context);
//                                                               } else {
//                                                                 setState(() {
//                                                                   mainloading =
//                                                                       false;
//                                                                 });
//                                                                 Get.snackbar(
//                                                                     "Failed",
//                                                                     saveinvoiceresponse[
//                                                                             "msg"]
//                                                                         .toString(),
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .red,
//                                                                     colorText:
//                                                                         Colors
//                                                                             .white);
//                                                               }
//                                                             } else {
//                                                               Get.snackbar(
//                                                                   "Failed",
//                                                                   "Please enter amount greater than or equal to grand total"
//                                                                       .toString(),
//                                                                   backgroundColor:
//                                                                       Colors
//                                                                           .red,
//                                                                   colorText:
//                                                                       Colors
//                                                                           .white);
//                                                             }
//                                                           }
//                                                         }
//                                                       }
//                                                     },
//                                                     elevation: 2.0,
//                                                     fillColor: Colors.green,
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             10.0),
//                                                     shape: const CircleBorder(
//                                                         side: BorderSide(
//                                                             color:
//                                                                 Colors.white)),
//                                                     child: const FaIcon(
//                                                       FontAwesomeIcons.check,
//                                                       color: Colors.white,
//                                                       size: 14,
//                                                     ),
//                                                   ),
//                                                   const Padding(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                             vertical: 2),
//                                                     child: Text(
//                                                       "SAVE",
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                           fontFamily:
//                                                               'Montserrat',
//                                                           color: Colors.black,
//                                                           fontSize: 10,
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Column(
//                                                 children: [
//                                                   RawMaterialButton(
//                                                     onPressed: () {},
//                                                     elevation: 2.0,
//                                                     fillColor: Colors.red,
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             10.0),
//                                                     shape: const CircleBorder(
//                                                         side: BorderSide(
//                                                             color:
//                                                                 Colors.white)),
//                                                     child: const FaIcon(
//                                                       FontAwesomeIcons.close,
//                                                       color: Colors.white,
//                                                       size: 14,
//                                                     ),
//                                                   ),
//                                                   const Padding(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                             vertical: 2),
//                                                     child: Text(
//                                                       "CANCEL",
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                           fontFamily:
//                                                               'Montserrat',
//                                                           color: Colors.black,
//                                                           fontSize: 10,
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Column(
//                                                 children: [
//                                                   RawMaterialButton(
//                                                     onPressed: () {},
//                                                     elevation: 2.0,
//                                                     fillColor: Colors.blue,
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             10.0),
//                                                     shape: const CircleBorder(
//                                                         side: BorderSide(
//                                                             color:
//                                                                 Colors.white)),
//                                                     child: const FaIcon(
//                                                       FontAwesomeIcons
//                                                           .fileInvoice,
//                                                       color: Colors.white,
//                                                       size: 14,
//                                                     ),
//                                                   ),
//                                                   const Padding(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                             vertical: 2),
//                                                     child: Text(
//                                                       "POST",
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                           fontFamily:
//                                                               'Montserrat',
//                                                           color: Colors.black,
//                                                           fontSize: 10,
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Column(
//                                                 children: [
//                                                   RawMaterialButton(
//                                                     onPressed: () async {
//                                                       // setState(() {
//                                                       //   loading = true;
//                                                       // });
//                                                       // const PaperSize paper =
//                                                       //     PaperSize.mm80;
//                                                       // final profile =
//                                                       //     await CapabilityProfile
//                                                       //         .load();
//                                                       // final printer =
//                                                       //     NetworkPrinter(
//                                                       //         paper, profile);
//                                                       // final PosPrintResult res =
//                                                       //     await printer.connect(
//                                                       //         '10.39.1.114',
//                                                       //         port: 9100);
//                                                       // if (res ==
//                                                       //     PosPrintResult
//                                                       //         .success) {
//                                                       //   final dynamic
//                                                       //       calculationresponse =
//                                                       //       await API
//                                                       //           .convertData(
//                                                       //               model.cart);
//                                                       //   API.printInvoice(
//                                                       //       printer,
//                                                       //       calculationresponse[
//                                                       //           "items"],
//                                                       //       calculationresponse[
//                                                       //               "total"]
//                                                       //           .toString(),
//                                                       //       calculationresponse[
//                                                       //               "vat"]
//                                                       //           .toString(),
//                                                       //       imagebytes);
//                                                       //   printer.disconnect();
//                                                       //   setState(() {
//                                                       //     loading = false;
//                                                       //   });
//                                                       // }
//                                                       // print(
//                                                       //     'Print result: ${res.msg}');
//                                                     },
//                                                     elevation: 2.0,
//                                                     fillColor: Colors.amber,
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             10.0),
//                                                     shape: const CircleBorder(
//                                                         side: BorderSide(
//                                                             color:
//                                                                 Colors.white)),
//                                                     child: const FaIcon(
//                                                       FontAwesomeIcons
//                                                           .fileInvoice,
//                                                       color: Colors.white,
//                                                       size: 14,
//                                                     ),
//                                                   ),
//                                                   const Padding(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                             vertical: 2),
//                                                     child: Text(
//                                                       "PRINT",
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: TextStyle(
//                                                           fontFamily:
//                                                               'Montserrat',
//                                                           color: Colors.black,
//                                                           fontSize: 10,
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                                 ],
//                               )),
//                               Container(
//                                 width: 1,
//                                 color: API.bordercolor,
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width / 5.5,
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 5, top: 5),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Column(
//                                                   children: [
//                                                     RawMaterialButton(
//                                                       onPressed: () async {
//                                                         final dynamic result =
//                                                             await API.scanQR();
//                                                         print(result);
//                                                         if (result == "-1") {
//                                                           Get.snackbar("Failed",
//                                                               "Please scan to search items",
//                                                               backgroundColor:
//                                                                   Colors.red,
//                                                               colorText:
//                                                                   Colors.white);
//                                                         } else {
//                                                           print(
//                                                               "This is the result");
//                                                           print(result);
//                                                           final dynamic
//                                                               searchresponse =
//                                                               await API
//                                                                   .getItemsQueryList(
//                                                                       "",
//                                                                       result,
//                                                                       widget
//                                                                           .token);
//                                                           print("Thi is resp");
//                                                           print(searchresponse);
//                                                           if (searchresponse
//                                                                   .length ==
//                                                               0) {
//                                                             Get.snackbar(
//                                                                 "Failed",
//                                                                 "No Items Found",
//                                                                 backgroundColor:
//                                                                     Colors.red,
//                                                                 colorText:
//                                                                     Colors
//                                                                         .white);
//                                                           } else {
//                                                             print(
//                                                                 "This is search response");
//                                                             print(
//                                                                 searchresponse);
//                                                             final data = {
//                                                               'id':
//                                                                   searchresponse[
//                                                                           0]!
//                                                                       .id,
//                                                               'part_number':
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .partnumber,
//                                                               'description':
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .description,
//                                                               "brand_id":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .brandid,
//                                                               "brand_name":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .brandname,
//                                                               "rate":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .rate,
//                                                               "quantity":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .quantity,
//                                                               "warehouse_id":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .warehouseid,
//                                                               "unit_name":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .unit_name,
//                                                               "unit_id":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .unit_id,
//                                                               "arr_units":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .arr_units,
//                                                               "tax_code":
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .tax_code
//                                                             };
//                                                             setState(() {
//                                                               itemdetails =
//                                                                   data;
//                                                               selectedunit =
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .arr_units[0];
//                                                               array_units =
//                                                                   searchresponse[
//                                                                           0]
//                                                                       .arr_units;
//                                                             });
//                                                             print(itemdetails);
//                                                           }
//                                                         }
//                                                       },
//                                                       elevation: 2.0,
//                                                       fillColor: Colors.green,
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               5.0),
//                                                       shape: const CircleBorder(
//                                                           side: BorderSide(
//                                                               color: Colors
//                                                                   .white)),
//                                                       child: const FaIcon(
//                                                         FontAwesomeIcons
//                                                             .barcode,
//                                                         color: Colors.white,
//                                                         size: 14,
//                                                       ),
//                                                     ),
//                                                     const Padding(
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                               vertical: 2),
//                                                       child: Text(
//                                                         "Scanner",
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         style: TextStyle(
//                                                             fontFamily:
//                                                                 'Montserrat',
//                                                             color: Colors.black,
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w500),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Column(
//                                                   children: [
//                                                     RawMaterialButton(
//                                                       onPressed: () {
//                                                         model.removeAll();
//                                                       },
//                                                       elevation: 2.0,
//                                                       fillColor: Colors.red,
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               5.0),
//                                                       shape: const CircleBorder(
//                                                           side: BorderSide(
//                                                               color: Colors
//                                                                   .white)),
//                                                       child: const FaIcon(
//                                                         FontAwesomeIcons.trash,
//                                                         color: Colors.white,
//                                                         size: 14,
//                                                       ),
//                                                     ),
//                                                     const Padding(
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                               vertical: 2),
//                                                       child: Text(
//                                                         "Clear All",
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         style: TextStyle(
//                                                             fontFamily:
//                                                                 'Montserrat',
//                                                             color: Colors.black,
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w500),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               height: 2,
//                                             ),
//                                             Divider(
//                                               color: API.bordercolor,
//                                             ),
//                                             SizedBox(
//                                               height: 2,
//                                             ),
//                                             Text(
//                                               "No of items",
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontFamily: 'Montserrat'),
//                                             ),
//                                             Text(
//                                               model.cart.length.toString(),
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w400,
//                                                   fontFamily: 'Montserrat'),
//                                             ),
//                                             // SizedBox(height: 10),
//                                             // Text(
//                                             //   "Total (before discount)",
//                                             //   textAlign: TextAlign.start,
//                                             //   style: TextStyle(
//                                             //       color: Colors.black,
//                                             //       fontSize: 12,
//                                             //       fontWeight: FontWeight.w600,
//                                             //       fontFamily: 'Montserrat'),
//                                             // ),
//                                             // Text(
//                                             //   model.totalPriceBefore.toString(),
//                                             //   textAlign: TextAlign.start,
//                                             //   style: TextStyle(
//                                             //       color: Colors.black,
//                                             //       fontSize: 13,
//                                             //       fontWeight: FontWeight.w400,
//                                             //       fontFamily: 'Montserrat'),
//                                             // ),
//                                             // SizedBox(height: 10),
//                                             // Text(
//                                             //   "Discount",
//                                             //   textAlign: TextAlign.start,
//                                             //   style: TextStyle(
//                                             //       color: Colors.black,
//                                             //       fontSize: 12,
//                                             //       fontWeight: FontWeight.w600,
//                                             //       fontFamily: 'Montserrat'),
//                                             // ),
//                                             // Text(
//                                             //   model.totaldiscount.toString(),
//                                             //   textAlign: TextAlign.start,
//                                             //   style: TextStyle(
//                                             //       color: Colors.black,
//                                             //       fontSize: 13,
//                                             //       fontWeight: FontWeight.w400,
//                                             //       fontFamily: 'Montserrat'),
//                                             // ),
//                                             SizedBox(height: 3),
//                                             Text(
//                                               "Sub Total",
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontFamily: 'Montserrat'),
//                                             ),
//                                             Text(
//                                               model.totalPrice.toString(),
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w400,
//                                                   fontFamily: 'Montserrat'),
//                                             ),
//                                             SizedBox(height: 3),
//                                             Text(
//                                               "vat",
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontFamily: 'Montserrat'),
//                                             ),
//                                             Text(
//                                               model.totalvat.toString(),
//                                               textAlign: TextAlign.start,
//                                               style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w400,
//                                                   fontFamily: 'Montserrat'),
//                                             ),
//                                             SizedBox(
//                                               height: 2,
//                                             ),
//                                             Divider(
//                                               color: API.bordercolor,
//                                             ),
//                                             SizedBox(
//                                               height: 2,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceAround,
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           top: 2, bottom: 4),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         "Receipt Type"
//                                                             .toUpperCase(),
//                                                         textAlign:
//                                                             TextAlign.start,
//                                                         style: TextStyle(
//                                                             color: Colors.black,
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontFamily:
//                                                                 'Montserrat'),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   width: MediaQuery.of(context)
//                                                           .size
//                                                           .width /
//                                                       6,
//                                                   height: 40,
//                                                   child: InputDecorator(
//                                                     decoration: InputDecoration(
//                                                         filled: true,
//                                                         fillColor:
//                                                             const Color.fromRGBO(
//                                                                 248, 248, 253, 1),
//                                                         enabledBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       4.0),
//                                                           borderSide:
//                                                               BorderSide(
//                                                             color:
//                                                                 API.bordercolor,
//                                                             width: 1.0,
//                                                           ),
//                                                         ),
//                                                         focusedBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       4.0),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color: Colors.green,
//                                                             width: 1.0,
//                                                           ),
//                                                         ),
//                                                         hintStyle: const TextStyle(
//                                                             fontFamily:
//                                                                 'Montserrat',
//                                                             color: Color.fromRGBO(
//                                                                 181, 184, 203, 1),
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                             fontSize: 14),
//                                                         contentPadding:
//                                                             const EdgeInsets.fromLTRB(
//                                                                 10.0,
//                                                                 10.0,
//                                                                 10.0,
//                                                                 10.0),
//                                                         // ignore: unnecessary_null_comparison
//                                                         hintText:
//                                                             'Receipt Type',
//                                                         border: OutlineInputBorder(
//                                                             borderRadius:
//                                                                 BorderRadius.circular(
//                                                                     4.0))),
//                                                     child:
//                                                         DropdownButtonHideUnderline(
//                                                       child: DropdownButton<
//                                                           dynamic>(
//                                                         isExpanded: true,
//                                                         dropdownColor:
//                                                             Colors.white,
//                                                         hint: const Text(
//                                                           'Choose Type',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Color
//                                                                       .fromRGBO(
//                                                                           135,
//                                                                           141,
//                                                                           186,
//                                                                           1),
//                                                               fontFamily:
//                                                                   'Montserrat',
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                               fontSize: 14),
//                                                         ),
//                                                         value:
//                                                             selectedreceipttype,
//                                                         isDense: true,
//                                                         onChanged:
//                                                             (data) async {
//                                                           setState(() {
//                                                             selectedreceipttype =
//                                                                 data;
//                                                           });
//                                                         },
//                                                         items: receipttype
//                                                             .map((value) {
//                                                           return DropdownMenuItem<
//                                                                   dynamic>(
//                                                               value: value,
//                                                               child: Container(
//                                                                 decoration: BoxDecoration(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             5.0)),
//                                                                 height: 20.0,
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .fromLTRB(
//                                                                         10.0,
//                                                                         2.0,
//                                                                         10.0,
//                                                                         0.0),
//                                                                 child:
//                                                                     Container(
//                                                                   child: Text(
//                                                                     value['type']
//                                                                         .toString()
//                                                                         .toUpperCase(),
//                                                                     style: TextStyle(
//                                                                         fontFamily:
//                                                                             'Montserrat',
//                                                                         color: API
//                                                                             .textcolor,
//                                                                         fontWeight:
//                                                                             FontWeight
//                                                                                 .w500,
//                                                                         fontSize:
//                                                                             14),
//                                                                   ),
//                                                                 ),
//                                                               ));
//                                                         }).toList(),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceAround,
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           top: 2, bottom: 4),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         "Received Amount"
//                                                             .toUpperCase(),
//                                                         textAlign:
//                                                             TextAlign.start,
//                                                         style: TextStyle(
//                                                             color: Colors.black,
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontFamily:
//                                                                 'Montserrat'),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   width: MediaQuery.of(context)
//                                                           .size
//                                                           .width /
//                                                       6,
//                                                   height: 40,
//                                                   // color: Colors.red,
//                                                   child: TextFormField(
//                                                     controller:
//                                                         receivedamountcontroller,
//                                                     keyboardType:
//                                                         TextInputType.number,
//                                                     style: TextStyle(
//                                                         color: API.textcolor,
//                                                         fontWeight:
//                                                             FontWeight.w400),
//                                                     decoration: InputDecoration(
//                                                         filled: true,
//                                                         fillColor:
//                                                             const Color.fromRGBO(
//                                                                 248, 248, 253, 1),
//                                                         enabledBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       4.0),
//                                                           borderSide:
//                                                               BorderSide(
//                                                             color:
//                                                                 API.bordercolor,
//                                                             width: 1.0,
//                                                           ),
//                                                         ),
//                                                         focusedBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       4.0),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color: Colors.green,
//                                                             width: 1.0,
//                                                           ),
//                                                         ),
//                                                         hintStyle: const TextStyle(
//                                                             fontFamily:
//                                                                 'Montserrat',
//                                                             color: Color.fromRGBO(
//                                                                 181, 184, 203, 1),
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                             fontSize: 14),
//                                                         contentPadding:
//                                                             const EdgeInsets.fromLTRB(
//                                                                 10.0,
//                                                                 10.0,
//                                                                 10.0,
//                                                                 10.0),
//                                                         // ignore: unnecessary_null_comparison
//                                                         hintText:
//                                                             'Received Amount',
//                                                         border: OutlineInputBorder(
//                                                             borderRadius:
//                                                                 BorderRadius.circular(
//                                                                     4.0))),
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                             selectedreceipttype["code"] == "CA"
//                                                 ? Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceAround,
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                     .only(
//                                                                 top: 2,
//                                                                 bottom: 4),
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               "Authorization Code"
//                                                                   .toUpperCase(),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .start,
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize: 10,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600,
//                                                                   fontFamily:
//                                                                       'Montserrat'),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                       Container(
//                                                         width: MediaQuery.of(
//                                                                     context)
//                                                                 .size
//                                                                 .width /
//                                                             6,
//                                                         height: 40,
//                                                         // color: Colors.red,
//                                                         child: TextFormField(
//                                                           controller:
//                                                               authorizationcodecontroller,
//                                                           keyboardType:
//                                                               TextInputType
//                                                                   .number,
//                                                           style: TextStyle(
//                                                               color:
//                                                                   API.textcolor,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w400),
//                                                           decoration:
//                                                               InputDecoration(
//                                                                   filled: true,
//                                                                   fillColor:
//                                                                       const Color.fromRGBO(
//                                                                           248,
//                                                                           248,
//                                                                           253,
//                                                                           1),
//                                                                   enabledBorder:
//                                                                       OutlineInputBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             4.0),
//                                                                     borderSide:
//                                                                         BorderSide(
//                                                                       color: API
//                                                                           .bordercolor,
//                                                                       width:
//                                                                           1.0,
//                                                                     ),
//                                                                   ),
//                                                                   focusedBorder:
//                                                                       OutlineInputBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             4.0),
//                                                                     borderSide:
//                                                                         const BorderSide(
//                                                                       color: Colors
//                                                                           .green,
//                                                                       width:
//                                                                           1.0,
//                                                                     ),
//                                                                   ),
//                                                                   hintStyle: const TextStyle(
//                                                                       fontFamily:
//                                                                           'Montserrat',
//                                                                       color: Color.fromRGBO(
//                                                                           181,
//                                                                           184,
//                                                                           203,
//                                                                           1),
//                                                                       fontWeight: FontWeight
//                                                                           .w500,
//                                                                       fontSize:
//                                                                           14),
//                                                                   contentPadding:
//                                                                       const EdgeInsets.fromLTRB(
//                                                                           10.0,
//                                                                           10.0,
//                                                                           10.0,
//                                                                           10.0),
//                                                                   // ignore: unnecessary_null_comparison
//                                                                   hintText:
//                                                                       'Code',
//                                                                   border: OutlineInputBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(4.0))),
//                                                         ),
//                                                       )
//                                                     ],
//                                                   )
//                                                 : SizedBox()
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 2,
//                                       ),
//                                       Divider(
//                                         color: API.bordercolor,
//                                       ),
//                                       SizedBox(
//                                         height: 2,
//                                       ),
//                                       Container(
//                                           height: MediaQuery.of(context)
//                                                   .size
//                                                   .height /
//                                               7,
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 10, top: 5),
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceAround,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Grand Total",
//                                                   textAlign: TextAlign.start,
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 12,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontFamily: 'Montserrat'),
//                                                 ),
//                                                 Text(
//                                                   (double.parse(
//                                                               (model.totalPrice)
//                                                                   .toString()) +
//                                                           double.parse(
//                                                               (model.totalvat)
//                                                                   .toString()))
//                                                       .toStringAsFixed(2),
//                                                   textAlign: TextAlign.start,
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 15,
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       fontFamily: 'Montserrat'),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 10,
//                                                 ),
//                                                 receivedamountcontroller
//                                                             .text.isEmpty ||
//                                                         (double.parse((model
//                                                                         .totalPrice)
//                                                                     .toString()) +
//                                                                 double.parse((model
//                                                                         .totalvat)
//                                                                     .toString())) <=
//                                                             0
//                                                     ? SizedBox()
//                                                     : Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                             "Balance",
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .green,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                           Text(
//                                                             (double.parse((double.parse((model.totalPrice).toString()) +
//                                                                             double.parse((model.totalvat)
//                                                                                 .toString()))
//                                                                         .toStringAsFixed(
//                                                                             2)) -
//                                                                     double.parse(
//                                                                         receivedamountcontroller
//                                                                             .text))
//                                                                 .toStringAsFixed(
//                                                                     2),
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TextStyle(
//                                                                 color:
//                                                                     Colors.red,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600,
//                                                                 fontFamily:
//                                                                     'Montserrat'),
//                                                           ),
//                                                         ],
//                                                       )
//                                               ],
//                                             ),
//                                           ))
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ));
//     });
//   }
// }
