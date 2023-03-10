import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/addcustomer.dart';

import '../loading_screen.dart';

class Customers extends StatefulWidget {
  final String token;
  final Map<String, dynamic> usbdevice;
  final Map<String, dynamic> userdetails;
  const Customers(
      {Key? key,
      required this.token,
      required this.usbdevice,
      required this.userdetails})
      : super(key: key);

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  bool loading = false;
  List<dynamic> customerslist = [];
  bool error = false;
  String message = "";
  TextEditingController termController = TextEditingController();
  loadFromServer() async {
    setState(() {
      loading = true;
    });
    final dynamic customerslistresponse =
        await API.customersListAPI(widget.token, termController.text, 0);
    if (customerslistresponse["status"] == "success") {
      setState(() {
        customerslist = customerslistresponse["data"];
        loading = false;
      });
    } else {
      setState(() {
        error = true;
        message = customerslistresponse["msg"].toString();
        loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    Future.delayed(Duration(seconds: 0), () async {
      loadFromServer();
      termController.addListener(() {
        loadFromServer();
      });
    });
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Customers",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: TextStyle(),
                  cursorColor: Colors.grey,
                  controller: termController,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),

                    hintText: "Search customer here",
                    filled: true, //<-- SEE HERE
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                slideRightWidget(
                    newPage: AddCustomer(
                      type: "0",
                      token: widget.token,
                      usbdevice: widget.usbdevice,
                      userdetails: widget.userdetails,
                    ),
                    context: context);
              },
              icon: Icon(Icons.add, color: Colors.white)),
          SizedBox(
            width: 30,
          )
        ],
      ),
      body: loading
          ? const LoadingScreen()
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView.separated(
                itemCount: customerslist.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/images/man.png"),
                    ),
                    title: Text(
                      customerslist[index]["name"].toString().toUpperCase(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat'),
                    ),
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20, top: 5),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.mobile_friendly,
                                  color: Colors.green,
                                  size: 15,
                                ),
                              ),
                              Text(
                                customerslist[index]["phone"].toString() == ""
                                    ? "Not Mentioned"
                                    : customerslist[index]["phone"]
                                        .toString()
                                        .toUpperCase(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.email,
                                  color: Colors.green,
                                  size: 15,
                                ),
                              ),
                              Text(
                                customerslist[index]["email"].toString() == ""
                                    ? "Not Mentioned"
                                    : customerslist[index]["email"]
                                        .toString()
                                        .toUpperCase(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.map_rounded,
                                color: Colors.red,
                                size: 15,
                              ),
                            ),
                            Text(
                              customerslist[index]["location"].toString() == ""
                                  ? "Not Mentioned"
                                  : customerslist[index]["location"]
                                      .toString()
                                      .toUpperCase(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        openEditCustomer(index);
                      },
                      icon: Icon(Icons.edit_outlined),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: API.bordercolor,
                  );
                },
              ),
            ),
    );
  }

  void openEditCustomer(int index) {
    slideRightWidget(
        newPage: AddCustomer(
          type: "0",
          customerId: customerslist[index]["id"].toString(),
          token: widget.token,
          usbdevice: widget.usbdevice,
          userdetails: widget.userdetails,
        ),
        context: context);
  }
}
