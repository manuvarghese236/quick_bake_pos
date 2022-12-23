import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/dashboard.dart';
import 'package:windowspos/frontend/homepage.dart';
import 'package:windowspos/frontend/successpage.dart';

class AddCustomer extends StatefulWidget {
  final String type;
  final String token;
  final Map<String, dynamic> usbdevice;
  final Map<String, dynamic> userdetails;
  const AddCustomer(
      {Key? key,
      required this.type,
      required this.token,
      required this.usbdevice,
      required this.userdetails})
      : super(key: key);

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  TextEditingController customernamecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();

  Map<String, dynamic> selectedlocation = {};
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: API.tilecolor,
        title: Text(
          "Add Customers",
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width / 1.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Name",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextField(
                    controller: customernamecontroller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(248, 248, 253, 1),
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        hintText: "Customer Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)))),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width / 1.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Mobile",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextField(
                    controller: mobilecontroller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(248, 248, 253, 1),
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        hintText: "Mobile",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)))),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width / 1.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(248, 248, 253, 1),
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)))),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width / 1.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Location",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextField(
                    controller: locationcontroller,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(248, 248, 253, 1),
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        hintText: "Location",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)))),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 9,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 5, top: 5),
                        child: InkWell(
                          onTap: () async {
                            if (customernamecontroller.text.isEmpty) {
                              Get.snackbar("Failed", "Please add customer name",
                                  backgroundColor: Colors.white,
                                  maxWidth:
                                      MediaQuery.of(context).size.width / 4,
                                  colorText: Colors.red);
                            } else {
                              setState(() {
                                loading = true;
                              });
                              final dynamic savecustomerresponse =
                                  await API.saveCustomerAPI(
                                      customernamecontroller.text,
                                      mobilecontroller.text.isEmpty
                                          ? ""
                                          : mobilecontroller.text,
                                      emailcontroller.text.isEmpty
                                          ? ""
                                          : emailcontroller.text,
                                      locationcontroller.text.isEmpty
                                          ? ""
                                          : locationcontroller.text,
                                      widget.token);
                              print(savecustomerresponse);
                              if (savecustomerresponse["status"] == "success") {
                                if (widget.type == "0") {
                                  pushWidgetWhileRemove(
                                      newPage: SuccessPage(screen: dashboard()),
                                      context: context);
                                } else {
                                  Navigator.pop(context);
                                  pushWidget(
                                      newPage: HomePage(
                                          token: widget.token,
                                          userdetails: widget.userdetails,
                                          usbdevice: widget.usbdevice,
                                          selectedcustomerid:
                                              savecustomerresponse["data"]
                                                  ["user_id"]),
                                      context: context);
                                }
                              } else {
                                Get.snackbar(
                                    "Failed", savecustomerresponse["message"],
                                    backgroundColor: Colors.white,
                                    colorText: Colors.red,
                                    maxWidth:
                                        MediaQuery.of(context).size.width / 4);
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: API.bordercolor),
                                color: Colors.white),
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            width: MediaQuery.of(context).size.width / 1.15,
                            height: 48,
                            child: Center(
                              child: Text(
                                "ADD NOW",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: API.textcolor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
