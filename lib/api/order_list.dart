import 'dart:convert';

import 'package:http/http.dart';
import 'package:windowspos/api/api.dart';
import 'dart:convert';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as im;

import '../cart/cart.dart';
import '../models/printermodel.dart';

class OrderListApi {
  static Future<Map<String, dynamic>> getlist(
      String term,
      String date,
      String salesmanid,
      String locationid,
      String receiptType,
      String customerLocationId,
      String token) async {
    String baseurl = API.baseurl;
    print(token);
    String url =
        '${baseurl}apiorder/getlist&order_date=${date}&sales_man_id=${salesmanid}&warehouse_id=${locationid}&term=${term}&type=$receiptType&customer_location_id=$customerLocationId';
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

  static Future<String> printOrderWindows(
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
      String companytrn,
      String subtotal,
      String discount,

      /// totalwithoutvat
      String totalwithoutvat,
      String totalvat,
      String grandtotal,
      String customeraddress,
      String time,
      String invoiceid,
      dynamic rowimage,
      Map<String, dynamic> footerDeatils) async {
    try {
      final imageHeadingBytes = await API.generateHeadingImageFromString(
        "طلب المبيعات",
      );
      final imageBytes = await API.generateImageFromString(
        "رقم الأمر",
      );
      final imageSubTotalBytes = await API.generateImageFromString(
        "المبلغ الاجمالي",
      );
      final imageDateBytes = await API.generateImageFromString(
        "تاريخ",
      );
      final imageOutletBytes = await API.generateImageFromString(
        "مَنفَذ",
      );
      final imageSalesmanBytes = await API.generateImageFromString(
        "بائع",
      );
      final imageCustomerBytes = await API.generateImageFromString(
        "الزبون",
      );
      final imagePhoneBytes = await API.generateImageFromString(
        "هاتف",
      );
      final imageAddressBytes = await API.generateImageFromString(
        "عنوان",
      );
      final imageRoundOff = await API.generateImageFromString(
        "نهاية الجولة",
      );
      final imageDiscountBytes = await API.generateImageFromString("تخفيض");
      final imageTotalwoVatBytes =
          await API.generateImageFromString("إجمالي بدون ضريبة");
      final imageVatBytes = await API.generateImageFromString("الضريبة");
      final imageGrandTotalBytes =
          await API.generateImageFromString("المجموع الإجمالي");
      print("Receipt type");

      final profile = await CapabilityProfile.load(name: 'XP-N160I');
      final printer = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      bytes += printer.image(logoimage);
      //bytes += printer.emptyLines(1);
      bytes += printer.text(companyaddress,
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += printer.text(companyphone,
          styles: const PosStyles(align: PosAlign.center));
      // bytes += printer.text("TRN : " + companytrn,
      //     styles: PosStyles(align: PosAlign.center));
      //bytes += printer.emptyLines(1);
      //bytes += printer.image(im.decodeImage(imageHeadingBytes)!);
      bytes += printer.text('SALES ORDER',
          styles: const PosStyles(
            bold: true,
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      //bytes += printer.emptyLines(1);
      bytes += printer.image(im.decodeImage(imageBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Order No",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $invoiceno",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 9),
      ]);

      bytes +=
          printer.image(im.decodeImage(imageDateBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Date",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $time",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      // bytes += printer.image(im.decodeImage(imageOutletBytes)!,
      //     align: PosAlign.left);
      // bytes += printer.row([
      //   PosColumn(
      //       text: "Outlet",
      //       styles: PosStyles(bold: true, align: PosAlign.left),
      //       width: 3),
      //   PosColumn(
      //       text: ": $outletname",
      //       styles: PosStyles(bold: true, align: PosAlign.left),
      //       width: 9)
      // ]);
      bytes += printer.image(im.decodeImage(imageSalesmanBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Salesman",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $salesman",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.image(im.decodeImage(imageCustomerBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Customer",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $customername",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes +=
          printer.image(im.decodeImage(imagePhoneBytes)!, align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
            text: "Phone",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": $customerphone",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      bytes += printer.row([
        PosColumn(
            text: "Location",
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 3),
        PosColumn(
            text: ": " + footerDeatils["emirates"].toString(),
            styles: const PosStyles(bold: true, align: PosAlign.left),
            width: 9)
      ]);
      LineSplitter ls = LineSplitter();
      List<String> _masForUsing = ls.convert(customeraddress);
      if (_masForUsing.length > 0) {
        bytes += printer.row([
          PosColumn(
              text: "Address",
              styles: const PosStyles(bold: true, align: PosAlign.left),
              width: 3),
          PosColumn(
              text: ": " + _masForUsing[0],
              styles: const PosStyles(bold: true, align: PosAlign.left),
              width: 9)
        ]);
      } else {
        bytes += printer.row([
          PosColumn(
              text: "Address",
              styles: const PosStyles(bold: true, align: PosAlign.left),
              width: 3),
          PosColumn(
              text: ": $customeraddress",
              styles: const PosStyles(bold: true, align: PosAlign.left),
              width: 9)
        ]);
      }
      for (var i = 1; i < _masForUsing.length; i++) {
        bytes += printer.row([
          PosColumn(
              text: _masForUsing[i],
              styles: const PosStyles(bold: true, align: PosAlign.left),
              width: 12)
        ]);
      }
      // } else {
      //   /// if address is greater than 30
      //   String address1 = customeraddress.substring(0, 30);
      //   String address2 = customeraddress.substring(30, customeraddress.length);
      //   bytes += printer.row([
      //     PosColumn(
      //         text: "Address",
      //         styles: const PosStyles(bold: true, align: PosAlign.left),
      //         width: 3),
      //     PosColumn(
      //         text: ": " + address1,
      //         styles: const PosStyles(bold: true, align: PosAlign.left),
      //         width: 9)
      //   ]);
      //   bytes += printer.row([
      //     PosColumn(
      //         text: address2,
      //         styles: const PosStyles(bold: true, align: PosAlign.left),
      //         width: 12)
      //   ]);
      // }
      //bytes += printer.emptyLines(1);
      bytes += printer.hr();
      bytes += printer.image(im.decodeImage(rowimage)!);
      bytes += printer.row([
        PosColumn(
            text: "Sl",
            styles: const PosStyles(
              bold: true,
            ),
            width: 1),
        PosColumn(
            text: "Description", styles: const PosStyles(bold: true), width: 5),
        PosColumn(text: "Qty", styles: const PosStyles(bold: true), width: 2),
        PosColumn(text: "Rate", styles: const PosStyles(bold: true), width: 2),
        PosColumn(
            text: "Amount", styles: const PosStyles(bold: true), width: 2),
      ]);
      bytes += printer.hr();
      int qty = 0;
      for (int i = 0; i < itemslist.length; i++) {
        if (itemslist[i]["inventory_item_type"] == "1") {
          String description = itemslist[i]["description"].toString();

          qty += SimpleConvert.safeDouble(
                  itemslist[i]["quantity"].toString().replaceAll(",", ""))
              .toInt();
          bytes += printer.row([
            PosColumn(
                text: (i + 1).toString(),
                styles: const PosStyles(bold: false),
                width: 1),
            PosColumn(
                text: (description.length > 15)
                    ? description.substring(0, 15)
                    : description,
                styles: const PosStyles(bold: false),
                width: 5),
            PosColumn(
                text: itemslist[i]["quantity"] == ""
                    ? ""
                    : SimpleConvert.safeDouble(itemslist[i]["quantity"])
                            .toStringAsFixed(0) +
                        " " +
                        itemslist[i]["unit_name"].toString(),
                styles: const PosStyles(bold: false, align: PosAlign.left),
                width: 2),
            PosColumn(
                text: itemslist[i]["rate"] == ""
                    ? ""
                    : SimpleConvert.safeDouble(itemslist[i]["rate"])
                        .toStringAsFixed(2),
                styles: const PosStyles(bold: false, align: PosAlign.left),
                width: 2),
            PosColumn(
                text: (SimpleConvert.safeDouble(itemslist[i]["rate"]) *
                        SimpleConvert.safeDouble(itemslist[i]["quantity"]))
                    .toStringAsFixed(2),
                styles: const PosStyles(bold: false, align: PosAlign.right),
                width: 2),
          ]);
          if ((description.length > 15)) {
            bytes += printer.row([
              PosColumn(
                  text: "", styles: const PosStyles(bold: false), width: 1),
              PosColumn(
                  text: description.substring(15),
                  styles: const PosStyles(bold: true, align: PosAlign.left),
                  width: 11)
            ]);
          }
        }
      }
      bytes += printer.hr();
      bytes += printer.row([
        PosColumn(
          text: "Total Qty",
          styles: const PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: const PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: qty.toString(),
            styles: const PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);

      /// Now Delivery Items
      for (int i = 0; i < itemslist.length; i++) {
        if (itemslist[i]["inventory_item_type"] == "2") {
          bytes += printer.row([
            PosColumn(
                text:
                    //  itemslist[i]["part_number"] +
                    //     " " +
                    itemslist[i]["description"],
                styles: const PosStyles(bold: false),
                width: 4),
            PosColumn(
              text: ":",
              styles: const PosStyles(bold: false, align: PosAlign.right),
              width: 2,
            ),
            PosColumn(
                text: (SimpleConvert.safeDouble(itemslist[i]["rate"]) *
                        SimpleConvert.safeDouble(itemslist[i]["quantity"]))
                    .toStringAsFixed(2),
                styles: const PosStyles(bold: false, align: PosAlign.right),
                width: 6),
          ]);
        }
      }

      bytes += printer.image(im.decodeImage(imageSubTotalBytes)!,
          align: PosAlign.left);
      bytes += printer.row([
        PosColumn(
          text: "Sub Total",
          styles: const PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: const PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text:
                SimpleConvert.safeDouble(footerDeatils["sub_total"].toString())
                    .toStringAsFixed(2),
            styles: const PosStyles(bold: false, align: PosAlign.right),
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
          styles: const PosStyles(bold: false, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: const PosStyles(bold: false, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: discount == ""
                ? ""
                : SimpleConvert.safeDouble(discount.toString() == ""
                        ? "0.00"
                        : discount.toString())
                    .toStringAsFixed(2),
            styles: const PosStyles(bold: false, align: PosAlign.right),
            width: 6),
      ]);
      bytes +=
          printer.image(im.decodeImage(imageRoundOff)!, align: PosAlign.left);
      bytes += printer.hr();
      String round_off = footerDeatils["round_off"].toString();
      bytes += printer.row([
        PosColumn(
          text: "Round Off",
          styles: const PosStyles(bold: true, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: const PosStyles(bold: true, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: round_off == ""
                ? ""
                : SimpleConvert.safeDouble(round_off.toString())
                    .toStringAsFixed(2),
            styles: const PosStyles(bold: true, align: PosAlign.right),
            width: 6),
      ]);

      bytes += printer.image(im.decodeImage(imageGrandTotalBytes)!,
          align: PosAlign.left);

      bytes += printer.row([
        PosColumn(
          text: "Grand Total",
          styles: const PosStyles(bold: true, align: PosAlign.left),
          width: 4,
        ),
        PosColumn(
          text: ":",
          styles: const PosStyles(bold: true, align: PosAlign.right),
          width: 2,
        ),
        PosColumn(
            text: grandtotal == ""
                ? ""
                : SimpleConvert.safeDouble(grandtotal.toString())
                    .toStringAsFixed(2),
            styles: const PosStyles(bold: true, align: PosAlign.right),
            width: 6),
      ]);
      bytes += printer.hr();

      //bytes += printer.emptyLines(1);
      bytes += printer.text('Thank you !! Visit Again',
          styles: const PosStyles(align: PosAlign.center));
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
      return "success";
    } catch (e) {
      print("this is catch part. $e");
      return e.toString();
    }
  }

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
}
