import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windowspos/cart/cart.dart';
import 'package:windowspos/models/brandmodel.dart';
import 'package:windowspos/models/customermodel.dart';
import 'package:windowspos/models/itemmodel.dart';
import 'package:windowspos/models/locationmodel.dart';
import 'package:windowspos/models/salesmanmodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image/image.dart' as im;

import '../models/contact.dart';
import '../models/printermodel.dart';

class API {
  static Color background = Color(0xFFf5f5f5);
  static Color bordercolor = Color(0xFF546E7A);
  static Color textcolor = Colors.black;
  static Color tilecolor = Color(0xFF451a00);
  static Color tilewhite = Colors.white;

  static String APP_VER = "1.0.1.17";
  static String CODE = "QUICKBAKE";
  static String baseurl = "http://pos.cumuluserp.me/quickbake/index.php?r=";
  static String imgurl = "http://pos.cumuluserp.me/quickbake/";

  static String DISPLAY_TYPE_STOCK_PROUDCT = "1";
  static String DISPLAY_TYPE_ALL_PROUDCT = "2";

  static TextStyle textdetailstyle() {
    return TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.7);
  }

  static getInfo() {
    var uri = Uri.parse(baseurl);
    String title =
        "${uri.host}${uri.path.replaceAll("/index.php", "")} Ver : $CODE $APP_VER";
    return title;
  }

  static generatePDF(
      List<dynamic> itemslist,
      String totalamount,
      String vat,
      dynamic logoimage,
      String invoiceno,
      String customername,
      String invoicedate,
      String outletname,
      String grandtotal,
      String companyname,
      String companyaddress,
      String companyphone,
      String customerphone,
      String salesman,
      String receipttype,
      String receivedamount,
      Uint8List image,
      String trnno) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Container(
              child: pw.Container(
                  // color: PdfColors.yellow,
                  child: pw.Center(
                      child: pw.Image(pw.MemoryImage(image),
                          height: PdfPageFormat.cm * 1.5,
                          width: PdfPageFormat.cm * 10))),
            ),
            pw.SizedBox(height: PdfPageFormat.mm * 1.5),
            pw.Container(
                height: PdfPageFormat.cm,
                // color: PdfColors.green,
                child: pw.Center(
                    child: pw.Text(companyaddress,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.normal,
                            fontSize: 9)))),
            pw.Container(
                height: 12,
                // color: PdfColors.green,
                child: pw.Center(
                    child: pw.Text(companyphone,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.normal,
                            fontSize: 9)))),
            pw.Container(
                height: 12,
                // color: PdfColors.green,
                child: pw.Center(
                    child: pw.Text(trnno,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.normal,
                            fontSize: 9)))),
            pw.SizedBox(height: PdfPageFormat.mm * 1.5),
            pw.Container(
                height: PdfPageFormat.cm,
                // color: PdfColors.green,
                child: pw.Center(
                    child: pw.Text('INVOICE',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 13)))),
            pw.SizedBox(height: PdfPageFormat.mm * 2),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2,
                  // color: PdfColors.green,
                  child: pw.Text('Invoice No',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 3,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $invoiceno",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2,
                  // color: PdfColors.green,
                  child: pw.Text('Date',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 3,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $invoicedate",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2,
                  // color: PdfColors.green,
                  child: pw.Text('Outlet',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 3,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $outletname",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2,
                  // color: PdfColors.green,
                  child: pw.Text('Salesman',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 3,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $salesman",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2,
                  // color: PdfColors.green,
                  child: pw.Text('Customer',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 7,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $customername",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2,
                  // color: PdfColors.green,
                  child: pw.Text('Phone',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 7,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $customerphone",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.SizedBox(height: PdfPageFormat.mm * 3),
            pw.Divider(
                height: PdfPageFormat.mm, thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: PdfPageFormat.mm * 1.5),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                        height: 13,
                        // color: PdfColors.green,
                        child: pw.Text('Itemcode',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9))),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                        height: 13,
                        // color: PdfColors.green,
                        child: pw.Text('Rate',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9))),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                        height: 13,
                        // color: PdfColors.green,
                        child: pw.Text('Qty',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9))),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                        height: 13,
                        // color: PdfColors.green,
                        child: pw.Text('Unit',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9))),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                        height: 13,
                        // color: PdfColors.green,
                        child: pw.Text('Amount',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9))),
                  )
                ]),
            pw.SizedBox(height: PdfPageFormat.mm * 1.5),
            pw.Divider(
                height: PdfPageFormat.mm, thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: PdfPageFormat.mm * 1.5),
            pw.Container(
              // color: PdfColors.blue,
              child: pw.ListView.separated(
                  itemBuilder: (Context, i) {
                    return pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                                height: 11,
                                // color: PdfColors.green,
                                child: pw.Text(itemslist[i]["part_number"],
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.normal,
                                        fontSize: 9))),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                                height: 11,
                                // color: PdfColors.green,
                                child: pw.Text(
                                    SimpleConvert.safeDouble(
                                            itemslist[i]["rate"])
                                        .toStringAsFixed(2),
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.normal,
                                        fontSize: 9))),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                                height: 11,
                                // color: PdfColors.green,
                                child: pw.Text(
                                    SimpleConvert.safeDouble(
                                            itemslist[i]["quantity"])
                                        .toStringAsFixed(2),
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.normal,
                                        fontSize: 9))),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                                height: 11,
                                // color: PdfColors.green,
                                child: pw.Text(itemslist[i]["unit_name"],
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.normal,
                                        fontSize: 9))),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                                height: 11,
                                // color: PdfColors.green,
                                child: pw.Text(
                                    SimpleConvert.safeDouble(
                                            itemslist[i]["total_amount"])
                                        .toStringAsFixed(2),
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.normal,
                                        fontSize: 9))),
                          )
                        ]);
                  },
                  itemCount: itemslist.length,
                  separatorBuilder: (Context, int index) {
                    return pw.SizedBox(height: PdfPageFormat.mm * 1.1);
                  }),
            ),
            pw.SizedBox(height: PdfPageFormat.mm * 2.5),
            pw.Divider(
                height: PdfPageFormat.mm, thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: PdfPageFormat.mm * 2.5),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2.2,
                  // color: PdfColors.green,
                  child: pw.Text('Total',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm,
                  // color: PdfColors.green,

                  child: pw.Text(":   ",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 4,
                  // color: PdfColors.green,
                  child: pw.Text(
                      SimpleConvert.safeDouble(totalamount.toString())
                          .toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2.2,
                  // color: PdfColors.green,
                  child: pw.Text('VAT',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm,
                  // color: PdfColors.green,

                  child: pw.Text(":   ",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 4,
                  // color: PdfColors.green,

                  child: pw.Text(
                      SimpleConvert.safeDouble(vat.toString())
                          .toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9))),
            ]),
            pw.SizedBox(height: PdfPageFormat.mm * 1.1),
            pw.Divider(
                height: PdfPageFormat.mm, thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: PdfPageFormat.mm * 1.1),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2.2,
                  // color: PdfColors.green,
                  child: pw.Text('Grand Total',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm,
                  // color: PdfColors.green,

                  child: pw.Text(":   ",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 4,
                  // color: PdfColors.green,
                  child: pw.Text(
                      SimpleConvert.safeDouble(grandtotal.toString())
                          .toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10))),
            ]),
            pw.SizedBox(height: PdfPageFormat.mm * 4),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2.2,
                  // color: PdfColors.green,
                  child: pw.Text('Receipt Type',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 3,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $receipttype",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 9))),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 2.2,
                  // color: PdfColors.green,
                  child: pw.Text('Received Amt',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 9))),
              pw.Container(
                  height: 12,
                  width: PdfPageFormat.cm * 7,
                  // color: PdfColors.green,
                  child: pw.Text(" :   $receivedamount",
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 9))),
            ]),
            pw.SizedBox(height: PdfPageFormat.mm * 4),
            pw.Container(
                height: 12,
                width: PdfPageFormat.cm * 7,

                // color: PdfColors.green,
                child: pw.Text('Thank You!! Visit Again',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.normal,
                        fontSize: 9))),
          ]);
        }));
    await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'posreceipt-${DateTime.now().millisecond.toString()}.pdf');
  }

  static Future<Map<String, dynamic>> savePDFToLocalDirectory(
      String nameofreport, Uint8List pdfdata) async {
    try {
      var dir = await getDownloadsDirectory();
      print(dir);
      File file = File("${dir!.path}/$nameofreport.pdf");
      await file.writeAsBytes(pdfdata);
      return {'status': 'success', 'path': "${dir.path}/$nameofreport.pdf"};
    } catch (e) {
      return {"status": "failed"};
    }
  }

  static Future<List<ItemSchema>> getItemsQueryList(String term, String barcode,
      String warehouseId, String token, String displayType) async {
    final itemsearch =
        '${baseurl}apistore/getlist&term=$term&bar_code=$barcode&warehouse_id=$warehouseId&display_type=$displayType';
    print(token);
    print(itemsearch);
    print(itemsearch);
    final response = await get(
      Uri.parse(itemsearch),
      headers: {"Accept": "application/json", 'token': token},
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List itemslist = json.decode(response.body)["data"];
      return itemslist.map((json) => ItemSchema.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<CustomerSchema>> getCustomerQueryList(
      String term, bool type, String token) async {
    String typedata = type == true ? "1" : "0";
    final customersearch =
        '${baseurl}apicustomer/GetList&term=$term&all=$typedata';

    print(token);
    print(customersearch);
    final response = await get(
      Uri.parse(customersearch),
      headers: {"Accept": "application/json", 'token': token},
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List customerlist = json.decode(response.body)["data"];
      return customerlist.map((json) => CustomerSchema.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<SalesManSchema>> getSalesmanQueryList(
      String term, bool type, String token) async {
    String typedata = type == true ? "1" : "0";
    final userssearch = '${baseurl}api/getuserlist&term=$term&all=$typedata';
    print(token);
    print(userssearch);
    final response = await get(
      Uri.parse(userssearch),
      headers: {"Accept": "application/json", 'token': token},
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List userslist = json.decode(response.body)["data"];
      return userslist.map((json) => SalesManSchema.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<LocationSchema>> getLocationsQueryList(
      String term, String token) async {
    final locationsearch = '${baseurl}api/getwarehouselist&term=$term';
    print(token);
    print(locationsearch);
    final response = await get(
      Uri.parse(locationsearch),
      headers: {"Accept": "application/json", 'token': token},
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List locationslist = json.decode(response.body)["data"];
      return locationslist
          .map((json) => LocationSchema.fromJson(json))
          .toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<BrandSchema>> getBrandsQueryList(
      String term, String token) async {
    final brandsearch = '${baseurl}Apistore/Brand&term=$term';
    print(token);
    print(brandsearch);
    final response = await get(
      Uri.parse(brandsearch),
      headers: {"Accept": "application/json", 'token': token},
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List brandslist = json.decode(response.body)["data"];
      return brandslist.map((json) => BrandSchema.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }
  // static Future<List<SalesManSchema>> getSalesmanQueryList(String term) async {
  //   print(term);
  //   List<dynamic> response = salesmanlist
  //       .where((element) => element["name"]
  //           .toString()
  //           .toLowerCase()
  //           .contains(term.toLowerCase()))
  //       .toList();
  //   print(response);
  //   return response.map((json) => SalesManSchema.fromJson(json)).toList();
  // }

  // static Future<List<LocationSchema>> getLocationsQueryList(String term) async {
  //   print(term);
  //   List<dynamic> response = locationslist
  //       .where((element) => element["name"]
  //           .toString()
  //           .toLowerCase()
  //           .contains(term.toLowerCase()))
  //       .toList();
  //   print(response);
  //   return response.map((json) => LocationSchema.fromJson(json)).toList();
  // }

  static Future<Map<String, dynamic>> saveCustomerAPI(
      String id,
      String customername,
      String phone,
      String email,
      String location,
      String customerAddress,
      List<CustomerContact> ContactList,
      String token) async {
    List arrContacts = [];
    for (var element in ContactList) {
      arrContacts.add(element.getJson());
    }
    var data = json.encode({
      "id": id,
      "customer_name": customername,
      "email": email,
      "location": location,
      "phone": phone,
      "customer_address": customerAddress,
      "arr_contacts": arrContacts
    });
    print(token);
    print(data);
    String url = '${baseurl}apicustomer/savecustomer';
    final response = await post(Uri.parse(url),
        headers: {"Accept": "application/json", "token": token}, body: data);
    print(url);
    if (response.statusCode == 200) {
      dynamic savecustomerresponse = jsonDecode(response.body);
      print(savecustomerresponse);
      return savecustomerresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateInvoiceAPI(
      String invoiceid,
      String receipttype,
      String receivedamount,
      String authorizationcode,
      String token) async {
    print(token);
    print(json.encode({
      "invoice_id": invoiceid,
      "receipt_type": receipttype,
      "received_amount": receivedamount,
      "authorization_code": authorizationcode
    }));
    try {
      final response = await post(
          Uri.parse('${baseurl}apiinvoice/updateinvoicereceivedamount'),
          headers: {"Accept": "application/json", "token": token},
          body: json.encode({
            "invoice_id": invoiceid,
            "receipt_type": receipttype,
            "received_amount": receivedamount,
            "authorization_code": authorizationcode
          }));
      if (response.statusCode == 200) {
        dynamic updateinvoicerresponse = jsonDecode(response.body);
        print(updateinvoicerresponse);
        return updateinvoicerresponse;
      } else {
        return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
      }
    } on Exception catch (e) {
      return {'status': 'failed', 'msg': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> customersListAPI(
      String token, String term, int draw) async {
    String url = '${baseurl}apicustomer/GetList&term=${term}&draw=draw';
    print(url);
    final response = await get(
      Uri.parse(url),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic customerslistresponse = jsonDecode(response.body);
      print(customerslistresponse);
      return customerslistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> storeListAPI(String term, String brandid,
      String locationid, String displaytype, String token) async {
    print(Uri.parse(
        '${baseurl}Apistore/Getreport&term=$term&brand_id=$brandid&warehouse_id=$locationid&display_type=$displaytype'));
    final response = await get(
      Uri.parse(
          '${baseurl}Apistore/Getreport&term=$term&brand_id=$brandid&warehouse_id=$locationid&display_type=$displaytype'),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic storelistresponse = jsonDecode(response.body);
      print(storelistresponse);
      return storelistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> invoiceListAPI(
      String term,
      String date,
      String salesmanid,
      String locationid,
      String receiptType,
      String customerLocationId,
      String token) async {
    print(token);
    String url =
        '${baseurl}apiinvoice/GetList&invoice_date=${date}&sales_man_id=${salesmanid}&warehouse_id=${locationid}&term=${term}&type=$receiptType&customer_location_id=$customerLocationId';
    print(url);
    final response = await get(
      Uri.parse(url),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic invoicelistresponse = jsonDecode(response.body);
      print("In the api response");
      print(invoicelistresponse);
      return invoicelistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> commisionReportListAPI(
      String startdate, String enddate, String userid, String token) async {
    print(token);
    print(Uri.parse(
        '${baseurl}apiinvoice/GetCommisionlist&from_date=$startdate&to_date=$enddate&leadowner_id=$userid'));
    final response = await get(
      Uri.parse(
          '${baseurl}apiinvoice/GetCommisionlist&from_date=$startdate&to_date=$enddate&leadowner_id=$userid'),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic commisionlistresponse = jsonDecode(response.body);
      print("In the api response");
      print(commisionlistresponse);
      return commisionlistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> detailedCommisionReportListAPI(
      String startdate, String enddate, String userid, String token) async {
    print(token);
    print(Uri.parse(
        '${baseurl}apiinvoice/GetCommissionDetailedpdf&from_date=$startdate&to_date=$enddate&leadowner_id=$userid'));
    final response = await get(
      Uri.parse(
          '${baseurl}apiinvoice/GetCommissionDetailedpdf&from_date=$startdate&to_date=$enddate&leadowner_id=$userid'),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic detailedcommisionlistresponse = jsonDecode(response.body);
      print("In the api response");
      print(detailedcommisionlistresponse);
      return detailedcommisionlistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> itemSalesReportListAPI(
      String startdate, String enddate, String userid, String token) async {
    print(token);
    print(Uri.parse(
        '${baseurl}apiinvoice/GetItemSalespdf&from_date=$startdate&to_date=$enddate&leadowner_id=$userid'));
    final response = await get(
      Uri.parse(
          '${baseurl}apiinvoice/GetItemSalespdf&from_date=$startdate&to_date=$enddate&leadowner_id=$userid'),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic itemsaleslistresponse = jsonDecode(response.body);
      print("In the api response");
      print(itemsaleslistresponse);
      return itemsaleslistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> closingReportAPI(
      String startdate, String warehouseid, String token) async {
    print(token);
    print(Uri.parse('${baseurl}Apicashclosing/getbyuserpdf'));
    final response = await post(
        Uri.parse('${baseurl}Apicashclosing/getbyuserpdf'),
        headers: {"Accept": "application/json", "token": token},
        body: json.encode({"date": startdate, "warehouse_id": warehouseid}));
    if (response.statusCode == 200) {
      dynamic closingreportresponse = jsonDecode(response.body);
      print("In the api response");
      print(closingreportresponse);
      return closingreportresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> invoiceReportListAPI(
      String startdate,
      String enddate,
      String userid,
      String customerid,
      String type,
      String token) async {
    print(token);
    print(Uri.parse(
        '${baseurl}apiinvoice/GetInvoicelist&from_date=$startdate&to_date=$enddate&customer_id=$customerid&leadowner_id=$userid&type=$type'));
    final response = await get(
      Uri.parse(
          '${baseurl}apiinvoice/GetInvoicelist&from_date=$startdate&to_date=$enddate&customer_id=$customerid&leadowner_id=$userid&type=$type'),
      headers: {"Accept": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      dynamic invoicelistresponse = jsonDecode(response.body);
      print("In the api response");
      print(invoicelistresponse);
      return invoicelistresponse;
    } else {
      return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
    }
  }

  static Future<Map<String, dynamic>> loginAPI(
      String code, String username, String password) async {
    final userlogin = "${baseurl}api/Login";
    print(userlogin);
    print(
      json.encode({"code": code, "username": username, "password": password}),
    );
    try {
      final response = await post(
        Uri.parse(userlogin),
        body: json
            .encode({"code": code, "username": username, "password": password}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        dynamic loginresponse = jsonDecode(response.body);
        print(loginresponse);
        return loginresponse;
      } else {
        return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
      }
    } catch (err) {
      return {"status": "failed", "msg": err.toString()};
    }
  }

  static Future<Map<String, dynamic>> invoiceLoginValidateAPI(String userid,
      String password, String warehouseid, String mastercompanyid) async {
    final userlogin = "${baseurl}api/InvoiceLoginValidate";
    print(userlogin);
    print(
      json.encode({
        "user_id": userid,
        "password": password,
        "warehouse_id": warehouseid,
        "master_company_id": mastercompanyid
      }),
    );
    try {
      final response = await post(
        Uri.parse(userlogin),
        body: json.encode({
          "user_id": userid,
          "password": password,
          "warehouse_id": warehouseid,
          "master_company_id": mastercompanyid
        }),
      );
      if (response.statusCode == 200) {
        print(response.body);
        dynamic loginresponse = jsonDecode(response.body);
        print(loginresponse);
        return loginresponse;
      } else {
        return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
      }
    } catch (err) {
      return {"status": "failed", "msg": err.toString()};
    }
  }

  static Future<int> indexOfList(List<dynamic> data, String id) async {
    List<dynamic> response = [];
    for (int i = 0; i < data.length; i++) {
      print(data[i].id);
      print(id);
      if (data[i].id == id) {
        response.add(i);
      }
    }
    if (response.isEmpty) {
      return -1;
    } else {
      return response[0];
    }
  }

  /// this saving Invoice to the server.
  static Future<Map<String, dynamic>> saveInvoiceAPI(
    String orderId,
    String userid,
    String customerid,
    String contactId,
    List<dynamic> items,
    String receipttype,
    String receivedamount,
    String authorizationcode,
    String token,
    String cashamount,
    String cardamount,
    String footerDiscount,
    String footerDiscountPecentage,
    bool homeDelivery,
    String round_off,
    String grandTotal,
  ) async {
    final saveinvoiceurl = "${baseurl}apiinvoice/SaveInvoice";
    try {
      var data = json.encode(
        {
          "order_id": orderId,
          "created_by": userid,
          "receipt_type": receipttype,
          "received_amount": receivedamount,
          "authorization_code": authorizationcode,
          "customer_id": customerid,
          "contact_id": contactId,
          "items": items,
          "received_card_amount": cardamount,
          "received_cash_amount": cashamount,
          "footer_discount": footerDiscount,
          "footer_discount_percentage": footerDiscountPecentage,
          "home_delivery": homeDelivery ? "Y" : "N",
          "round_off": round_off,
          "grand_total": grandTotal
        },
      );
      print(saveinvoiceurl);
      print(token);
      print(data);
      print("------------------");
      final response = await post(
        Uri.parse(saveinvoiceurl),
        headers: {"Accept": "application/json", "token": token},
        body: data,
      );

      if (response.statusCode == 200) {
        dynamic saveinvoiceresponse = jsonDecode(response.body);
        print(saveinvoiceresponse);
        return saveinvoiceresponse;
      } else {
        print(response.body);
        print("saveInvoiceAPI failed " + response.reasonPhrase.toString());
        return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
      }
    } catch (err) {
      return {"status": "failed", "msg": err.toString()};
    }
  }

  static Future<Map<String, dynamic>> addPrefferenceUserDetails(
      String userid,
      String name,
      String token,
      String companyname,
      String billingaddress,
      String phone,
      String defaultCustomerId,
      String trnNo,
      String branchlink,
      String warehouseId,
      String warehouseName,
      String masterCompanyId,
      String barcodenabled) async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    try {
      blueskydehneepos.setString('user_id', userid);
      blueskydehneepos.setString('name', name);
      blueskydehneepos.setString('_token', token);
      blueskydehneepos.setString('company_name', companyname);
      blueskydehneepos.setString('billing_address', billingaddress);
      blueskydehneepos.setString('genral_phno', phone);
      blueskydehneepos.setString('default_customer_id', defaultCustomerId);
      blueskydehneepos.setString('trn_no', trnNo);
      blueskydehneepos.setString('branchlink', branchlink);
      blueskydehneepos.setString('warehouse_id', warehouseId);
      blueskydehneepos.setString('warehouse_name', warehouseName);
      blueskydehneepos.setString('master_company_id', masterCompanyId);
      blueskydehneepos.setString('barcodenabled', barcodenabled);
      return {'status': 'success', 'msg': 'done'};
    } catch (e) {
      return {'status': 'failed', 'msg': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addIpAddress(
    String ipaddress,
  ) async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    try {
      blueskydehneepos.setString('ipaddress', ipaddress);
      return {'status': 'success', 'msg': 'done'};
    } catch (e) {
      return {'status': 'failed', 'msg': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addUSBPrinter(
      String devicename, String vendorid, String productid) async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    try {
      blueskydehneepos.setString('devicename', devicename);
      blueskydehneepos.setString('vendorid', vendorid);
      blueskydehneepos.setString('productid', productid);
      return {'status': 'success', 'msg': 'done'};
    } catch (e) {
      return {'status': 'failed', 'msg': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUSBPrinter() async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    if (blueskydehneepos.containsKey('devicename')) {
      String? devicename = blueskydehneepos.getString('devicename');
      String? vendorid = blueskydehneepos.getString('vendorid');
      String? productid = blueskydehneepos.getString('productid');
      return {
        'status': 'success',
        'data': {
          'devicename': devicename,
          'vendorid': vendorid,
          'productid': productid
        }
      };
    } else {
      return {'status': 'failed', 'message': 'User not available'};
    }
  }

  static Future<bool> checkUsbPrinter(String usbdevicename) async {
    bool checkstatus = false;
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    if (blueskydehneepos.containsKey('devicename')) {
      if (blueskydehneepos.getString('devicename') == usbdevicename) {
        checkstatus = true;
      }
    }
    return checkstatus;
  }

  static Future<Map<String, dynamic>> getIpAddress() async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    if (blueskydehneepos.containsKey('ipaddress')) {
      String? ipaddress = blueskydehneepos.getString('ipaddress');
      return {
        'status': 'success',
        'ipaddress': ipaddress,
      };
    } else {
      return {'status': 'failed', 'message': 'User not available'};
    }
  }

  static Future<Map<String, dynamic>> getUserDetails() async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    if (blueskydehneepos.containsKey('user_id')) {
      String? userid = blueskydehneepos.getString('user_id');
      String? name = blueskydehneepos.getString('name');
      String? token = blueskydehneepos.getString('_token');
      String? companyname = blueskydehneepos.getString('company_name');
      String? billingaddress = blueskydehneepos.getString('billing_address');
      String? phoneno = blueskydehneepos.getString('genral_phno');
      String? defaultCustomerId =
          blueskydehneepos.getString('default_customer_id');
      String? trnNo = blueskydehneepos.getString('trn_no');
      String? branchlink = blueskydehneepos.getString('branchlink');
      String? warehouseId = blueskydehneepos.getString("warehouse_id");
      String? masterCompanyId = blueskydehneepos.getString("master_company_id");

      return {
        'status': 'success',
        'userid': userid,
        'name': name,
        'token': token,
        'company_name': companyname,
        'billing_address': billingaddress,
        'genral_phno': phoneno,
        'default_customer_id': defaultCustomerId,
        'trn_no': trnNo,
        'branchlink': branchlink,
        "warehouse_id": warehouseId,
        "master_company_id": masterCompanyId
      };
    } else {
      return {'status': 'failed', 'message': 'User not available'};
    }
  }

  static Future<String?> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    return barcodeScanRes;
  }

  static Future<Map<String, dynamic>> convertData(List<ItemSchema> data) async {
    num totalamount = 0.00;
    num totalvat = 0.00;
    List<dynamic> itemdetails = [];
    for (int i = 0; i < data.length; i++) {
      final eachresult = {
        "product_id": data[i].id,
        "description": data[i].description,
        "rate": data[i].rate,
        "quantity": data[i].quantity,
        "warehouse_id": data[i].warehouseid,
        "total_amount": data[i].totalAmount,
        "unit_id": data[i].unit_id,
        "tax_code": data[i].tax_code,
        "discount_amount": data[i].discountvalue,
        "discount_percentage": data[i].discount_percentage,
        "grand_total": data[i].totalafterdiscount,
        "tax_vat_amount":
            SimpleConvert.safeDouble(data[i].vatafterdiscount.toString()),
        "net_per_item":
            SimpleConvert.safeDouble(data[i].totalafterdiscount.toString()) /
                SimpleConvert.safeDouble(data[i].quantity.toString()),
      };
      print("This is the data inside cart send to backend");
      print(eachresult);
      itemdetails.add(eachresult);
    }
    return {"items": itemdetails};
    // return {"total": totalamount, "items": itemdetails, "vat": totalvat};
  }

  // static void printWindowsInvoice() {}

  static Future printReceiveTest(BluetoothPrinter selectedprinter) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('Test Print',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Product 1');
    bytes += generator.text('Product 2');
    _printEscPos(bytes, generator, selectedprinter);
  }

  /// print ticket
  static Future<void> _printEscPos(List<int> bytes, Generator generator,
      BluetoothPrinter selectedPrinter) async {
    print("inside pos");
    var bluetoothPrinter = selectedPrinter;
    bytes += generator.feed(2);
    bytes += generator.cut();
    print(bytes);
    await PrinterManager.instance.disconnect(type: selectedPrinter.typePrinter);
    await PrinterManager.instance.connect(
        type: bluetoothPrinter.typePrinter,
        model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId));
    print("connected");
    await PrinterManager.instance
        .send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    // await PrinterManager.instance.disconnect(type: selectedPrinter.typePrinter);
  }

  // static void printInvoice(
  //     BluetoothPrinter usbdevice,
  //     NetworkPrinter printer,
  //     List<dynamic> itemslist,
  //     String totalamount,
  //     String vat,
  //     dynamic logoimage,
  //     String invoiceno,
  //     String customername,
  //     String invoicedate,
  //     String outletname,
  //     String grandtotal,
  //     String companyname,
  //     String companyaddress,
  //     String companyphone,
  //     String customerphone,
  //     String salesman,
  //     String receipttype,
  //     String receivedamount) async {
  //   try {
  //     print("ipaddress ${ipaddress}");
  //     print("total amount ${totalamount}");
  //     final PosPrintResult res = await printer.connect(ipaddress,
  //         port: 9100, timeout: Duration(seconds: 15));
  //     print("Message of printer");
  //     print(res.msg);
  //     if (res == PosPrintResult.timeout) {
  //       printer.disconnect();
  //       Get.snackbar("Failed", "Printer connection timed out",
  //           backgroundColor: Colors.red, colorText: Colors.white);
  //     } else if (res == PosPrintResult.scanInProgress) {
  //       print("Scasnning in progress");
  //     } else if (res == PosPrintResult.success) {
  //       printer.image(logoimage);
  //       printer.emptyLines(1);
  //       printer.text(companyaddress,
  //           styles: PosStyles(align: PosAlign.center, bold: true));
  //       printer.text(companyphone, styles: PosStyles(align: PosAlign.center));
  //       printer.emptyLines(2);
  //       printer.text('TAX INVOICE',
  //           styles: PosStyles(
  //             bold: true,
  //             align: PosAlign.center,
  //             height: PosTextSize.size2,
  //             width: PosTextSize.size2,
  //           ));
  //       printer.emptyLines(1);
  //       printer.row([
  //         PosColumn(
  //             text: "Invoice No",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: ": " + invoiceno.toString(),
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: "Date ",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: ": " + invoicedate.toString(),
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //       ]);
  //       printer.row([
  //         PosColumn(
  //             text: "Outlet",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: ": " + outletname.toString(),
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 9)
  //       ]);
  //       printer.row([
  //         PosColumn(
  //             text: "Salesman",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: ": " + salesman.toString(),
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 9)
  //       ]);
  //       printer.emptyLines(1);
  //       printer.row([
  //         PosColumn(
  //             text: "Customer",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: ": " + customername.toString(),
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 9)
  //       ]);
  //       printer.row([
  //         PosColumn(
  //             text: "Phone",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 3),
  //         PosColumn(
  //             text: ": " + customerphone,
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 9)
  //       ]);
  //       printer.emptyLines(1);
  //       printer.hr();
  //       printer.row([
  //         PosColumn(text: "Item code", styles: PosStyles(bold: true), width: 4),
  //         PosColumn(text: "Rate", styles: PosStyles(bold: true), width: 2),
  //         PosColumn(text: "Qty", styles: PosStyles(bold: true), width: 2),
  //         PosColumn(text: "unit", styles: PosStyles(bold: true), width: 2),
  //         PosColumn(text: "Amount", styles: PosStyles(bold: true), width: 2),
  //       ]);
  //       printer.hr();
  //       for (int i = 0; i < itemslist.length; i++) {
  //         printer.row([
  //           PosColumn(
  //               text: itemslist[i]["part_number"],
  //               styles: PosStyles(bold: false),
  //               width: 4),
  //           PosColumn(
  //               text: itemslist[i]["rate"] == ""
  //                   ? ""
  //                   : SimpleConvert.safeDouble(itemslist[i]["rate"]).toStringAsFixed(2),
  //               styles: PosStyles(bold: false),
  //               width: 2),
  //           PosColumn(
  //               text: itemslist[i]["quantity"] == ""
  //                   ? ""
  //                   : SimpleConvert.safeDouble(itemslist[i]["quantity"]).toStringAsFixed(2),
  //               styles: PosStyles(bold: false),
  //               width: 2),
  //           PosColumn(
  //               text: itemslist[i]["unit_name"],
  //               styles: PosStyles(bold: false),
  //               width: 2),
  //           PosColumn(
  //               text: itemslist[i]["total_amount"] == ""
  //                   ? ""
  //                   : SimpleConvert.safeDouble(itemslist[i]["total_amount"])
  //                       .toStringAsFixed(2),
  //               styles: PosStyles(bold: false),
  //               width: 2),
  //         ]);
  //       }
  //       printer.hr();
  //       printer.row([
  //         PosColumn(
  //           text: "Total",
  //           styles: PosStyles(bold: false, align: PosAlign.right),
  //           width: 4,
  //         ),
  //         PosColumn(
  //           text: ":",
  //           styles: PosStyles(bold: false, align: PosAlign.right),
  //           width: 2,
  //         ),
  //         PosColumn(
  //             text: totalamount == ""
  //                 ? ""
  //                 : SimpleConvert.safeDouble(totalamount.toString()).toStringAsFixed(2),
  //             styles: PosStyles(bold: false, align: PosAlign.right),
  //             width: 6),
  //       ]);
  //       printer.row([
  //         PosColumn(
  //           text: "VAT",
  //           styles: PosStyles(bold: false, align: PosAlign.right),
  //           width: 4,
  //         ),
  //         PosColumn(
  //           text: ":",
  //           styles: PosStyles(bold: false, align: PosAlign.right),
  //           width: 2,
  //         ),
  //         PosColumn(
  //             text: vat == ""
  //                 ? ""
  //                 : SimpleConvert.safeDouble(vat.toString()).toStringAsFixed(2),
  //             styles: PosStyles(bold: false, align: PosAlign.right),
  //             width: 6),
  //       ]);
  //       printer.hr();
  //       printer.row([
  //         PosColumn(
  //           text: "Grand Total",
  //           styles: PosStyles(bold: true, align: PosAlign.right),
  //           width: 4,
  //         ),
  //         PosColumn(
  //           text: ":",
  //           styles: PosStyles(bold: true, align: PosAlign.right),
  //           width: 2,
  //         ),
  //         PosColumn(
  //             text: grandtotal == ""
  //                 ? ""
  //                 : SimpleConvert.safeDouble(grandtotal.toString()).toStringAsFixed(2),
  //             styles: PosStyles(bold: true, align: PosAlign.right),
  //             width: 6),
  //       ]);
  //       printer.hr();
  //       printer.emptyLines(2);
  //       printer.row([
  //         PosColumn(
  //             text: "Receipt Type",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 5),
  //         PosColumn(
  //             text: ": " + receipttype == "" ? "" : receipttype,
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 7)
  //       ]);
  //       printer.row([
  //         PosColumn(
  //             text: "Received Amount",
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 5),
  //         PosColumn(
  //             text: ": " + receivedamount == ""
  //                 ? ""
  //                 : SimpleConvert.safeDouble(receivedamount.toString()).toStringAsFixed(2),
  //             styles: PosStyles(bold: true, align: PosAlign.left),
  //             width: 7)
  //       ]);
  //       printer.emptyLines(2);
  //       printer.text('Thank you !! Visit Again',
  //           styles: PosStyles(align: PosAlign.center));
  //       printer.feed(2);
  //       printer.cut();
  //       printer.disconnect();
  //       Future.delayed(Duration(seconds: 3));
  //     } else {
  //       printer.disconnect();
  //       Get.snackbar("Failed", "Printer connection timed out",
  //           backgroundColor: Colors.red, colorText: Colors.white);
  //     }
  //   } catch (e) {
  //     printer.disconnect();
  //     print("this is catch part");
  //     print(e);
  //   }
  // }

  static Future<Map<String, dynamic>> duplicate(
      Map<String, dynamic> data) async {
    num subtotal = 0.00;
    num discount = 0.00;
    List<dynamic> items = [];

    for (int i = 0; i < data["items"].length; i++) {
      final dynamic datadetails = {
        "part_number": data["items"][i]["part_number"],
        "rate": data["items"][i]["rate"],
        "quantity": data["items"][i]["quantity"],
        "unit_name": data["items"][i]["unit_name"],
        "total_amount": SimpleConvert.safeDouble(
                (SimpleConvert.safeDouble(data["items"][i]["rate"]) *
                        SimpleConvert.safeDouble(data["items"][i]["quantity"]))
                    .toString())
            .toStringAsFixed(2)
      };
      subtotal += SimpleConvert.safeDouble(
          (SimpleConvert.safeDouble(data["items"][i]["rate"]) *
                  SimpleConvert.safeDouble(data["items"][i]["quantity"]))
              .toString());
      discount +=
          SimpleConvert.safeDouble(data["items"][i]["discount"].toString()) *
              SimpleConvert.safeDouble(data["items"][i]["quantity"]);
      items.add(datadetails);
    }
    num grandtotal = subtotal - discount;
    num vat = (grandtotal * 5) / 105;
    num totalamountwithoutvat = grandtotal - vat;

    return {
      "items": items,
      "subtotal": subtotal,
      "discount": discount,
      "totalwithoutvat": totalamountwithoutvat,
      "vat": vat,
      "grandtotal": grandtotal
    };
  }

  static Future<void> printInvoiceDuplicate(
      BluetoothPrinter usbdevice,
      NetworkPrinter printer,
      List<dynamic> itemslist,
      String totalamount,
      String vat,
      dynamic logoimage,
      String invoiceno,
      String customername,
      String invoicedate,
      String outletname,
      String grandtotal,
      String companyname,
      String companyaddress,
      String companyphone,
      String customerphone,
      String salesman,
      String receipttype,
      String receivedamount,
      String companytrn,
      String discount,
      String amountwithoutvat) async {
    try {
      print("Receipt type");
      print(receipttype);
      final profile = await CapabilityProfile.load(name: 'XP-N160I');
      final printer = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      bytes += printer.image(logoimage);
      bytes += printer.emptyLines(1);
      bytes += printer.text(companyaddress,
          styles: PosStyles(align: PosAlign.center, bold: true));
      bytes +=
          printer.text(companyphone, styles: PosStyles(align: PosAlign.center));
      bytes += printer.text("TRN : " + companytrn,
          styles: PosStyles(align: PosAlign.center));
      bytes += printer.emptyLines(2);
      bytes += printer.text('TAX INVOICE',
          styles: PosStyles(
            bold: true,
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      bytes += printer.emptyLines(1);
      bytes += printer.row([
        PosColumn(
            text: "Invoice No",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $invoiceno",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: "Date ",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $invoicedate",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Outlet",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $outletname",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Salesman",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $salesman",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.emptyLines(1);
      bytes += printer.row([
        PosColumn(
            text: "Customer",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $customername",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Phone",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $customerphone",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.emptyLines(1);
      bytes += printer.hr();
      bytes += printer.row([
        PosColumn(text: "Item code", styles: PosStyles(bold: true), width: 4),
        PosColumn(text: "Rate", styles: PosStyles(bold: true), width: 2),
        PosColumn(text: "Qty", styles: PosStyles(bold: true), width: 2),
        PosColumn(text: "Unit", styles: PosStyles(bold: true), width: 2),
        PosColumn(text: "Amount", styles: PosStyles(bold: true), width: 2),
      ]);
      bytes += printer.hr();
      for (int i = 0; i < itemslist.length; i++) {
        bytes += printer.row([
          PosColumn(
              text: itemslist[i]["part_number"],
              styles: PosStyles(bold: false),
              width: 4),
          PosColumn(
              text: itemslist[i]["rate"] == ""
                  ? ""
                  : SimpleConvert.safeDouble(itemslist[i]["rate"])
                      .toStringAsFixed(2),
              styles: PosStyles(bold: false),
              width: 2),
          PosColumn(
              text: itemslist[i]["quantity"] == ""
                  ? ""
                  : SimpleConvert.safeDouble(itemslist[i]["quantity"])
                      .toStringAsFixed(2),
              styles: PosStyles(bold: false),
              width: 2),
          PosColumn(
              text: itemslist[i]["unit_name"],
              styles: PosStyles(bold: false),
              width: 2),
          PosColumn(
              text: itemslist[i]["total_amount"] == ""
                  ? ""
                  : SimpleConvert.safeDouble(itemslist[i]["total_amount"])
                      .toStringAsFixed(2),
              styles: PosStyles(bold: false),
              width: 2),
        ]);
      }
      bytes += printer.hr();
      bytes += printer.row([
        PosColumn(
          text: "Sub Total",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: totalamount == ""
                ? ""
                : SimpleConvert.safeDouble(totalamount.toString() == ""
                        ? "0.00"
                        : totalamount.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.row([
        PosColumn(
          text: "Discount",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: discount == ""
                ? ""
                : SimpleConvert.safeDouble(discount.toString() == ""
                        ? "0.00"
                        : discount.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);
      /*
      bytes += printer.row([
        PosColumn(
          text: "Total w/t VAT",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: amountwithoutvat == ""
                ? ""
                : SimpleConvert.safeDouble(amountwithoutvat.toString() == ""
                        ? "0.00"
                        : amountwithoutvat.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]); 
      bytes += printer.row([
        PosColumn(
          text: "VAT",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: vat == ""
                ? ""
                : SimpleConvert.safeDouble(vat.toString() == "" ? "0.00" : vat.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]); */
      bytes += printer.hr();
      bytes += printer.row([
        PosColumn(
          text: "Grand Total",
          styles: PosStyles(bold: true, align: PosAlign.right),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: true, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: grandtotal == ""
                ? ""
                : SimpleConvert.safeDouble(grandtotal.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: true, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.hr();
      bytes += printer.emptyLines(2);
      bytes += printer.row([
        PosColumn(
            text: "Receipt Type",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 5),
        PosColumn(
            text: ": $receipttype" == ""
                ? ""
                : receipttype == "CH"
                    ? "CASH"
                    : "CARD",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 7)
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Received Amount",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 5),
        PosColumn(
            text: ": " + receivedamount == ""
                ? ""
                : SimpleConvert.safeDouble(receivedamount.toString() == ""
                        ? "0.00"
                        : receivedamount.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 7)
      ]);
      bytes += printer.emptyLines(2);
      bytes += printer.text('Thank you !! Visit Again',
          styles: PosStyles(align: PosAlign.center));
      print("In");
      await _printEscPos(
          bytes,
          printer,
          BluetoothPrinter(
              deviceName: usbdevice.deviceName,
              vendorId: usbdevice.vendorId,
              productId: usbdevice.productId,
              typePrinter: PrinterType.usb));
    } catch (e) {
      print("this is catch part");
      print(e);
    }
  }

  static Future<Uint8List> generateImageFromString(
    String text,
  ) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(
        recorder,
        Rect.fromCenter(
          center: Offset(0, 0),
          width: 600,
          height: 200,
        ));
    TextSpan span = TextSpan(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
        text: span,
        maxLines: 1,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr);
    tp.layout(minWidth: 100, maxWidth: 600);
    tp.paint(canvas, const Offset(0.0, 0.0));
    var picture = recorder.endRecording();
    final pngBytes = await picture.toImage(
      tp.size.width.toInt(),
      tp.size.height.toInt() - 2,
    );
    final byteData = await pngBytes.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> generateHeadingImageFromString(
    String text,
  ) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(
        recorder,
        Rect.fromCenter(
          center: Offset(0, 0),
          width: 600,
          height: 200,
        ));
    TextSpan span = TextSpan(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 40,
        fontWeight: FontWeight.w700,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
        text: span,
        maxLines: 1,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout(minWidth: 100, maxWidth: 600);
    tp.paint(canvas, const Offset(0.0, 0.0));
    var picture = recorder.endRecording();
    final pngBytes = await picture.toImage(
      tp.size.width.toInt(),
      tp.size.height.toInt() - 2,
    );
    final byteData = await pngBytes.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// This function for print invoice after saving.
  static void printInvoiceWindows(
      BluetoothPrinter usbdevice,
      NetworkPrinter printer,
      List<dynamic> itemslist,
      dynamic logoimage,
      String invoiceno,
      String customername,
      String invoicedate,
      String outletname,
      String companyname,
      String companyaddress,
      String companyphone,
      String customerphone,
      String salesman,
      String receipttype,
      String receivedamount,
      String companytrn,
      String subtotal,
      String discount,

      /// totalwithoutvat
      String totalwithoutvat,
      String totalvat,
      String grandtotal,
      String customeraddress,
      String cashcardCash,
      String cashcardCard,
      String time,
      String invoiceid,
      dynamic rowimage,
      Map<String, dynamic> footerDeatils) async {
    try {
      final imageHeadingBytes = await generateHeadingImageFromString(
        "???????????? ",
      );
      final imageBytes = await generateImageFromString(
        "?????? ????????????????",
      );
      final imageSubTotalBytes = await generateImageFromString(
        "???????????? ????????????????",
      );
      final imageDateBytes = await generateImageFromString(
        "??????????",
      );
      final imageOutletBytes = await generateImageFromString(
        "????????????",
      );
      final imageSalesmanBytes = await generateImageFromString(
        "????????",
      );
      final imageCustomerBytes = await generateImageFromString(
        "????????????",
      );
      final imagePhoneBytes = await generateImageFromString(
        "????????",
      );
      final imageAddressBytes = await generateImageFromString(
        "??????????",
      );
      final imageRoundOff = await API.generateImageFromString(
        "?????????? ????????????",
      );
      final imageDiscountBytes = await generateImageFromString("??????????");
      final imageTotalwoVatBytes =
          await generateImageFromString("???????????? ???????? ??????????");
      final imageVatBytes = await generateImageFromString("??????????????");
      final imageGrandTotalBytes =
          await generateImageFromString("?????????????? ????????????????");
      print("Receipt type");
      print(receipttype);
      final profile = await CapabilityProfile.load(name: 'XP-N160I');
      final printer = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      bytes += printer.image(logoimage);
      //bytes += printer.emptyLines(1);
      bytes += printer.text(companyaddress,
          styles: PosStyles(align: PosAlign.center, bold: true));
      bytes +=
          printer.text(companyphone, styles: PosStyles(align: PosAlign.center));
      // bytes += printer.text("TRN : " + companytrn,
      //     styles: PosStyles(align: PosAlign.center));
      //bytes += printer.emptyLines(1);
      //bytes += printer.image(im.decodeImage(imageHeadingBytes)!);
      bytes += printer.text('SALES INVOICE',
          styles: PosStyles(
            bold: true,
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      //bytes += printer.emptyLines(1);
      bytes += printer.image(im.decodeImage(imageBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Invoice No",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $invoiceno",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9),
        // PosColumn(
        //     text: "Date ",
        //     styles: PosStyles(bold: true, align: PosAlign.left),
        //     width: 2),
        // PosColumn(
        //     text: ": $invoicedate",
        //     styles: PosStyles(bold: true, align: PosAlign.left),
        //     width: 4),
      ]);
      // bytes += printer.row([
      //   PosColumn(
      //       text: "Date",
      //       styles: PosStyles(bold: true, align: PosAlign.left),
      //       width: 3),
      //   PosColumn(
      //       text: ": $invoicedate",
      //       styles: PosStyles(bold: true, align: PosAlign.left),
      //       width: 9)
      // ]);
      bytes +=
          printer.image(im.decodeImage(imageDateBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Date",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $time",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.image(im.decodeImage(imageOutletBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Outlet",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $outletname",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.image(im.decodeImage(imageSalesmanBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Salesman",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $salesman",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.image(im.decodeImage(imageCustomerBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Customer",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $customername",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes +=
          printer.image(im.decodeImage(imagePhoneBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Phone",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $customerphone",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Emirates",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": " + footerDeatils["emirates"].toString(),
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);

      // bytes += printer.image(im.decodeImage(imageAddressBytes)!,
      //     align: PosAlign.left);
      if (customeraddress.length <= 30) {
        bytes += printer.row([
          PosColumn(
              text: "Address",
              styles: PosStyles(bold: true, align: PosAlign.left),
              width: 3),
          PosColumn(
              text: ": $customeraddress",
              styles: PosStyles(bold: true, align: PosAlign.left),
              width: 9)
        ]);
      } else {
        /// if address is greater than 30
        bytes += printer.row([
          PosColumn(
              text: "Address",
              styles: PosStyles(bold: true, align: PosAlign.left),
              width: 3),
          PosColumn(
              text: ": " + customeraddress.substring(0, 30),
              styles: PosStyles(bold: true, align: PosAlign.left),
              width: 9)
        ]);
        bytes += printer.row([
          PosColumn(
              text: " ",
              styles: PosStyles(bold: true, align: PosAlign.left),
              width: 3),
          PosColumn(
              text: " " + customeraddress.substring(30, customeraddress.length),
              styles: PosStyles(bold: true, align: PosAlign.left),
              width: 9)
        ]);
      }
      //bytes += printer.emptyLines(1);
      bytes += printer.hr();
      bytes += printer.image(im.decodeImage(rowimage)!);
      bytes += printer.row([
        PosColumn(
            text: "Sl",
            styles: PosStyles(
              bold: true,
            ),
            width: 1),
        PosColumn(text: "Description", styles: PosStyles(bold: true), width: 5),
        PosColumn(text: "Rate", styles: PosStyles(bold: true), width: 2),
        PosColumn(text: "Qty", styles: PosStyles(bold: true), width: 2),
        // PosColumn(text: "unit", styles: PosStyles(bold: true), width: 1),
        PosColumn(text: "Amount", styles: PosStyles(bold: true), width: 2),
      ]);
      bytes += printer.hr();
      for (int i = 0; i < itemslist.length; i++) {
        bytes += printer.row([
          PosColumn(
              text:
                  //  itemslist[i]["part_number"] +
                  //     " " +
                  (i + 1).toString(),
              styles: PosStyles(bold: false),
              width: 1),
          PosColumn(
              text:
                  //  itemslist[i]["part_number"] +
                  //     " " +
                  itemslist[i]["description"],
              styles: PosStyles(bold: false),
              width: 5),
          PosColumn(
              text: itemslist[i]["rate"] == ""
                  ? ""
                  : SimpleConvert.safeDouble(itemslist[i]["rate"])
                      .toStringAsFixed(2),
              styles: PosStyles(bold: false, align: PosAlign.left),
              width: 2),
          PosColumn(
              text: itemslist[i]["quantity"] == ""
                  ? ""
                  : SimpleConvert.safeDouble(itemslist[i]["quantity"])
                      .toStringAsFixed(2),
              styles: PosStyles(bold: false, align: PosAlign.left),
              width: 2),
          // PosColumn(
          //     text: itemslist[i]["unit_name"],
          //     styles: PosStyles(bold: false),
          //     width: 1),
          PosColumn(
              text: (SimpleConvert.safeDouble(itemslist[i]["rate"]) *
                      SimpleConvert.safeDouble(itemslist[i]["quantity"]))
                  .toStringAsFixed(2),
              styles: PosStyles(bold: false, align: PosAlign.right),
              width: 2),
        ]);
      }
      bytes += printer.hr();
      bytes += printer.image(im.decodeImage(imageSubTotalBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
          text: "Sub Total",
          styles: PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: footerDeatils["sub_total"].toString(),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.image(im.decodeImage(imageDiscountBytes)!,
          align: PosAlign.left);
      discount = footerDeatils["discount"].toString();
      totalwithoutvat = footerDeatils["total_without_vat"].toString();
      totalvat = footerDeatils["vat"].toString();
      grandtotal = footerDeatils["grand_total"].toString();
      bytes += printer.row([
        PosColumn(
          text: "Discount",
          styles: PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: discount == ""
                ? ""
                : SimpleConvert.safeDouble(discount.toString() == ""
                        ? "0.00"
                        : discount.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.image(im.decodeImage(imageTotalwoVatBytes)!,
          align: PosAlign.left);
      /*
      bytes += printer.row([
        PosColumn(
          text: "Total w/t VAT",
          styles: PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: totalwithoutvat == ""
                ? ""
                : SimpleConvert.safeDouble(totalwithoutvat.toString() == ""
                        ? "0.00"
                        : totalwithoutvat.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]); 
      bytes +=
          printer.image(im.decodeImage(imageVatBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
          text: "VAT",
          styles: PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: totalvat == ""
                ? ""
                : SimpleConvert.safeDouble(totalvat.toString() == ""
                        ? "0.00"
                        : totalvat.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);*/

      bytes +=
          printer.image(im.decodeImage(imageRoundOff)!, align: PosAlign.left);
      bytes += printer.hr();
      String round_off = footerDeatils["round_off"].toString();
      bytes += printer.row([
        PosColumn(
          text: "Round Off",
          styles: PosStyles(bold: true, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: true, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: round_off == ""
                ? ""
                : SimpleConvert.safeDouble(round_off.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: true, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.hr();
      bytes += printer.image(im.decodeImage(imageGrandTotalBytes)!,
          align: PosAlign.left);

      bytes += printer.row([
        PosColumn(
          text: "Grand Total",
          styles: PosStyles(bold: true, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: PosStyles(bold: true, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: grandtotal == ""
                ? ""
                : SimpleConvert.safeDouble(grandtotal.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: true, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.hr();
      //bytes += printer.emptyLines(2);
      String ReceiptType = "";
      if (receipttype == "CH") {
        ReceiptType = "Cash";
      } else if (receipttype == "CR") {
        ReceiptType = "Credit Invoice";
      } else if (receipttype == "CA") {
        ReceiptType = "Card";
      } else if (receipttype == "CC") {
        ReceiptType = "Cash + Card";
      }

      bytes += printer.row([
        PosColumn(
            text: "Receipt Type",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 5),
        PosColumn(
            text: ReceiptType,
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 7)
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Received Amount",
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 5),
        PosColumn(
            text: ": " +
                SimpleConvert.safeDouble(receivedamount.toString() == ""
                        ? "0.00"
                        : receivedamount.toString())
                    .toStringAsFixed(2),
            styles: PosStyles(bold: true, align: PosAlign.left),
            width: 7)
      ]);
      bytes += printer.row([
        PosColumn(
            text: receipttype == "CC"
                ? "CASH : " +
                    SimpleConvert.safeDouble(
                            cashcardCash == "" ? "0.00" : cashcardCash)
                        .toStringAsFixed(2) +
                    " CARD : " +
                    SimpleConvert.safeDouble(
                            cashcardCard == "" ? "0.00" : cashcardCard)
                        .toStringAsFixed(2) +
                    ""
                : "",
            styles: PosStyles(bold: false, align: PosAlign.left),
            width: 12)
      ]);
      //bytes += printer.emptyLines(1);
      bytes += printer.text('Thank you !! Visit Again',
          styles: PosStyles(align: PosAlign.center));
      //bytes += printer.emptyLines(1);
      List<dynamic> invoiceidlistdata =
          invoiceno.split("").map(int.parse).toList();
      print(invoiceidlistdata);
      bytes += printer.barcode(Barcode.codabar(invoiceidlistdata),
          width: 10, height: 90);
      print("In");
      await _printEscPos(
          bytes,
          printer,
          BluetoothPrinter(
              deviceName: usbdevice.deviceName,
              vendorId: usbdevice.vendorId,
              productId: usbdevice.productId,
              typePrinter: PrinterType.usb));
    } catch (e) {
      print("this is catch part");
      print(e);
    }
  }

  getCustomerContact(String CustomerId, token) async {
    final url = '${baseurl}Apicustomer/GetContactList&id=$CustomerId';
    print(token);
    print(url);
    print(url);
    final response = await get(
      Uri.parse(url),
      headers: {"Accept": "application/json", 'token': token},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"status": "error", "message": response.reasonPhrase};
    }
  }
}
