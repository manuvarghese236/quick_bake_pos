import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:windowspos/api/api.dart';

import '../models/printermodel.dart';

class PrinterConfig extends StatefulWidget {
  final String selectedprinter;
  const PrinterConfig({Key? key, required this.selectedprinter})
      : super(key: key);

  @override
  State<PrinterConfig> createState() => _PrinterConfigState();
}

class _PrinterConfigState extends State<PrinterConfig> {
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scan();
  }

  void _scan() {
    devices.clear();
    _subscription = PrinterManager.instance
        .discovery(type: PrinterType.usb, isBle: false)
        .listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: false,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.usb,
      ));
      setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: API.tilecolor,
        title: Text(
          "Printer Config",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                    tileColor:
                        widget.selectedprinter == devices[index].deviceName
                            ? Colors.green
                            : Colors.white,
                    onTap: () async {
                      final dynamic addresponse = await API.addUSBPrinter(
                          devices[index].deviceName == null
                              ? ""
                              : devices[index].deviceName!.toString(),
                          devices[index].vendorId == null
                              ? ""
                              : devices[index].vendorId!.toString(),
                          devices[index].productId == null
                              ? ""
                              : devices[index].productId!.toString());
                      if (addresponse["status"] == "success") {
                        Get.snackbar("Success", "Ip Updated",
                            backgroundColor: Colors.green,
                            maxWidth: MediaQuery.of(context).size.width / 4,
                            colorText: Colors.white);
                      } else {
                        Get.snackbar("Failed", "Ip Updation error",
                            maxWidth: MediaQuery.of(context).size.width / 4,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    leading: Icon(Icons.print, color: API.tilecolor),
                    title: Text(
                      '${devices[index].deviceName}',
                      style: TextStyle(
                          color: widget.selectedprinter ==
                                  devices[index].deviceName
                              ? Colors.white
                              : Colors.black),
                    ));
              })),
    );
  }
}
