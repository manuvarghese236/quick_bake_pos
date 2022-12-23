import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/addcustomer.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    Future.delayed(Duration(seconds: 0), () async {
      setState(() {
        loading = true;
      });
      final dynamic customerslistresponse =
          await API.customersListAPI(widget.token);
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
        title: Text(
          "Customers",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400),
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
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: Colors.red,
              ),
            )
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
}
