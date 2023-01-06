import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/dashboard.dart';
import 'package:windowspos/frontend/homepage.dart';
import 'package:windowspos/frontend/successpage.dart';

import '../models/contact.dart';

class AddCustomer extends StatefulWidget {
  final String type;
  String? customerId;
  final String token;
  final Map<String, dynamic> usbdevice;
  final Map<String, dynamic> userdetails;
  AddCustomer(
      {Key? key,
      required this.type,
      this.customerId,
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
  TextEditingController Customeremailcontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController ContactphoneController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();
  final _formConact = GlobalKey<FormState>();
  Map<String, dynamic> selectedlocation = {};
  List<CustomerContact> ContactList = [];

  String SelectedLocationId = "";
  String selectedContactId = "";
  String token = "";
  String userId = "";
  int selectContactIndex = -1;
  List LocationList = [];
  bool EditContactEnable = true;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    loadMaster();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  loadMaster() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("_token").toString();
    userId = prefs.getString("user_id").toString();
    var LocationResponse = await getLocation(token);
    if (LocationResponse["status"] == "success") {
      setState(() {
        LocationList = LocationResponse['data'];
      });
    }
    if (widget.customerId != null && widget.customerId!.length > 0) {
      await loadCustomer();
    }
    setState(() {
      isLoading = false;
    });
  }

  loadCustomer() async {
    if (widget.customerId!.isNotEmpty) {
      String url =
          "${API.baseurl}Apicustomer/Customerdetails&id=${widget.customerId}";
      print(url);
      var res = await get(Uri.parse(url),
          headers: {"Accept": "application/json", "token": token});
      if (res.statusCode == 200) {
        print(res.body);
        var resBody = json.decode(res.body);
        if (resBody["status"] == "success") {
          var data = resBody['data'];
          customernamecontroller.text = data["customer_name"].toString();
          Customeremailcontroller.text = data["email"].toString();
          SelectedLocationId = data["location"].toString();
          mobilecontroller.text = data["phone"].toString();
          addresscontroller.text = data["address"].toString();
          ContactList.cast();
          for (var element in data["arr_contacts"]) {
            ContactList.add(CustomerContact(
                id: element["id"].toString(),
                person_name: element["person_name"].toString(),
                contact_mobile_no: element["contact_mobile_no"].toString(),
                latitude: element["latitude"].toString(),
                longitude: element["longitude"].toString()));
          }
          // if there is no contact, edit/add contact customer card shows
          EditContactEnable = (ContactList.length == 0);
          setState(() {
            print("");
          });
        }
      }
    }
  }

  getLocation(String token) async {
    String url = "${API.baseurl}Apicustomer/LocationList";
    print(url);
    print("token " + token);
    var res = await get(Uri.parse(url),
        headers: {"Accept": "application/json", "token": token});
    print(res.body);
    if (res.statusCode == 200) {
      var resBody = json.decode(res.body);

      return resBody;
    } else {
      return {"status": "error", "message": res.reasonPhrase};
    }
  }

  clearContact() {
    selectedContactId = "";

    nameController.text = "";
    ContactphoneController.text = "";
    latController.text = "";

    longController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: API.tilecolor,
        title: const Text(
          "Add Customers",
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
              setState(() {
                addNewContact();
              });
            },
            icon: const Icon(Icons.person_add_alt_1_outlined),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.30,
                          child: Card(
                            child: Column(
                              children: [
                                TextField(
                                    controller: customernamecontroller,
                                    decoration: const InputDecoration(
                                      labelText: "Customer Name",
                                      icon: Icon(Icons.person),
                                      hintText: "Customer Name",
                                    )),
                                const SizedBox(
                                  height: 2,
                                ),
                                TextField(
                                    controller: mobilecontroller,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: "Mobile",
                                      icon: Icon(Icons.phone_outlined),
                                      hintText: "Mobile",
                                    )),
                                const SizedBox(
                                  height: 2,
                                ),
                                TextField(
                                    controller: Customeremailcontroller,
                                    decoration: const InputDecoration(
                                      hintText: "Email",
                                      labelText: "Email",
                                      icon: Icon(Icons.email_outlined),
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                    controller: addresscontroller,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: "Address",
                                      labelText: "Address",
                                      icon: Icon(Icons.location_city_outlined),
                                    )),
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    hintText: "Location",
                                    labelText: "Location",
                                    icon: Icon(Icons.local_activity_outlined),
                                  ),
                                  value: LocationList.length > 0
                                      ? (SelectedLocationId.length > 0
                                          ? SelectedLocationId
                                          : null)
                                      : null,
                                  items: LocationList.map<
                                      DropdownMenuItem<String>>((var value) {
                                    return DropdownMenuItem<String>(
                                      value: value["id"].toString(),
                                      child: Text(
                                        value["location_name"],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    SelectedLocationId = val.toString();
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // here we start for contact
                        (!EditContactEnable)
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width / 2.30,
                                height: 40,
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        addNewContact();
                                      });
                                    },
                                    child: Text("Add New Contact")),
                              )
                            : SizedBox(),
                        Card(
                          color: Colors.grey.shade200,
                          child: (EditContactEnable)
                              ? Card(
                                  child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    key: _formConact,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          2.30,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            "Customer Contact",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: nameController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Required";
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                          hintText:
                                                              "Contact Name",
                                                          labelText:
                                                              "Contact Name",
                                                          icon: Icon(
                                                              Icons.person)),
                                                ),
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      ContactphoneController,
                                                  decoration:
                                                      const InputDecoration(
                                                          hintText:
                                                              "Contact Phone",
                                                          labelText:
                                                              "Contact Phone",
                                                          icon: Icon(Icons
                                                              .call_outlined)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: latController,
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                "Latitude",
                                                            labelText:
                                                                "Latitude",
                                                            icon: Icon(Icons
                                                                .location_on_outlined)),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: longController,
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                "Longitude",
                                                            labelText:
                                                                "Longitude",
                                                            icon: Icon(Icons
                                                                .location_on_outlined)),
                                                  ),
                                                ),
                                              ]),
                                          const SizedBox(height: 30),
                                          Container(
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .red)),
                                                      onPressed: () {
                                                        setState(() {
                                                          clearContact();
                                                          EditContactEnable =
                                                              false;
                                                        });
                                                      },
                                                      icon: const Icon(Icons
                                                          .cancel_outlined),
                                                      label: const Text(
                                                          "Cancel ")),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .green)),
                                                      onPressed: () {
                                                        if (_formConact
                                                            .currentState!
                                                            .validate()) {
                                                          CustomerContact data = CustomerContact(
                                                              id:
                                                                  selectedContactId,
                                                              person_name:
                                                                  nameController
                                                                      .text
                                                                      .toString(),
                                                              contact_mobile_no:
                                                                  ContactphoneController
                                                                      .text
                                                                      .toString(),
                                                              latitude:
                                                                  latController
                                                                      .text
                                                                      .toString(),
                                                              longitude:
                                                                  longController
                                                                      .text
                                                                      .toString());
                                                          clearContact();
                                                          setState(() {
                                                            if (selectContactIndex <
                                                                0) {
                                                              ContactList.add(
                                                                  data);
                                                            } else {
                                                              ContactList[
                                                                      selectContactIndex] =
                                                                  data;
                                                              selectContactIndex =
                                                                  -1;
                                                            }
                                                            EditContactEnable =
                                                                false;
                                                          });
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.done_outline),
                                                      label: const Text(
                                                          "Add Contact")),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                              : SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.31,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: ContactList.length,
                                    itemBuilder: ((context, index) {
                                      return ListTile(
                                        dense: true,
                                        leading:
                                            const Icon(Icons.person_outlined),
                                        title: Text(
                                            ContactList[index].person_name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(ContactList[index]
                                            .contact_mobile_no),
                                        trailing: IconButton(
                                            onPressed: () async {
                                              selectContactIndex = index;
                                              nameController.text =
                                                  ContactList[index]
                                                      .person_name;
                                              ContactphoneController.text =
                                                  ContactList[index]
                                                      .contact_mobile_no;
                                              latController.text =
                                                  ContactList[index].latitude;
                                              longController.text =
                                                  ContactList[index].longitude;
                                              selectedContactId =
                                                  ContactList[index].id;
                                              setState(() {
                                                EditContactEnable = true;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blueGrey,
                                            )),
                                      );
                                    }),
                                  ),
                                ),
                        )
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 10,
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 5, top: 5),
                              child: InkWell(
                                onTap: () async {
                                  if (customernamecontroller.text.isEmpty) {
                                    Get.snackbar(
                                        "Failed", "Please add customer name",
                                        backgroundColor: Colors.white,
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        colorText: Colors.red);
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final dynamic savecustomerresponse =
                                        await API.saveCustomerAPI(
                                            widget.customerId.toString(),
                                            customernamecontroller.text,
                                            mobilecontroller.text.isEmpty
                                                ? ""
                                                : mobilecontroller.text,
                                            Customeremailcontroller.text.isEmpty
                                                ? ""
                                                : Customeremailcontroller.text,
                                            SelectedLocationId,
                                            addresscontroller.text.toString(),
                                            ContactList,
                                            widget.token);

                                    print(savecustomerresponse);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (savecustomerresponse["status"] ==
                                        "success") {
                                      if (widget.type == "0") {
                                        pushWidgetWhileRemove(
                                            newPage: const SuccessPage(
                                                screen: dashboard()),
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
                                      Get.snackbar("Failed",
                                          savecustomerresponse["message"],
                                          backgroundColor: Colors.white,
                                          colorText: Colors.red,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4);
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border:
                                          Border.all(color: API.bordercolor),
                                      color: Colors.green),
                                  margin: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  height: 48,
                                  child: const Center(
                                    child: Text(
                                      "Save Customer",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          color: Colors.white,
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

  void addNewContact() {
    clearContact();
    selectContactIndex = -1;
    selectedContactId = "";
    EditContactEnable = true;
  }
}
