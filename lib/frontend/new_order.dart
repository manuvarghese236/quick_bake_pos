import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as im;

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/api/order_list.dart';
import 'package:windowspos/cart/cart.dart';
import 'package:windowspos/frontend/addcustomer.dart';
import 'package:windowspos/frontend/dashboard.dart';
import 'package:windowspos/frontend/successpage.dart';
import 'package:windowspos/models/contact.dart';
import 'package:windowspos/models/customermodel.dart';
import 'package:windowspos/models/itemmodel.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:windowspos/models/printermodel.dart';

import '../api/order_api.dart';
import '../loading_screen.dart';

class NewOrder extends StatefulWidget {
  final int numberInvoiceCopy = 2;
  final Map<String, dynamic> usbdevice;
  final String token;
  final Map<String, dynamic> userdetails;
  final String? selectedcustomerid;
  const NewOrder(
      {Key? key,
      required this.token,
      required this.userdetails,
      required this.usbdevice,
      this.selectedcustomerid})
      : super(key: key);

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  /// Allow negative Qty
  bool allowNegativeQty = true;

  /// saving order
  bool isLoading = false;

  /// TextEditingController
  TextEditingController receivedamountcontroller = TextEditingController();
  TextEditingController authorizationcodecontroller = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  FocusNode linediscountfocusnode = FocusNode();
  FocusNode footerDiscountNode = FocusNode();
  FocusNode barcodeFocusNode = FocusNode();
  FocusNode itemFocusnode = FocusNode();
  var customerContactList = [];
  String? selectedContact = null;
  CustomerContact? selectedCustomerContact;
  String userId = "0";
  String userWareHouseId = "";
  // TextEditingController cashpluscardcashcontroller = TextEditingController();
  // TextEditingController cashpluscardcardcontroller = TextEditingController();

  double footer_discount = 0.0;
  String footer_discount_text = "0.00";
  bool homeDelivery = false;
  late FocusNode focusnode;
  late FocusNode qtyfocusnode;
  dynamic imagebytes;
  Uint8List? imgdatabytes;
  Uint8List? imgrowdatabytes;

  Future getSetting() async {
    try {
      SharedPreferences blueskydehneepos =
          await SharedPreferences.getInstance();
      userWareHouseId = blueskydehneepos.getString("warehouse_id").toString();
      print("init State");

      if (blueskydehneepos.getString("barcodenabled").toString() == "Y") {
        print(" barcodenabled  => Y");
        barcodeswitch = true;
      } else {
        barcodeswitch = false;
        print(" barcodenabled  => N");
      }
      userId = blueskydehneepos.getString("user_id").toString();
      setState(() {});
    } catch (ex) {
      print(" Barcode Ex" + ex.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSetting();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    focusnode = FocusNode();
    qtyfocusnode = FocusNode();
    try {
      Future.delayed(const Duration(seconds: 0), () async {
        setState(() {
          mainloading = true;
        });
        final ByteData invoicedata = await rootBundle.load(
          'assets/images/logo2.png',
        );
        final Uint8List logoimgBytes = invoicedata.buffer.asUint8List();
        final dynamic logoimage = im.decodeImage(logoimgBytes);
        final ByteData invoicerowdata = await rootBundle.load(
          'assets/images/rowim.png',
        );
        final Uint8List logorowimgBytes = invoicerowdata.buffer.asUint8List();
        // print(logoimgBytes);
        final dynamic customerdetailsresponse =
            await API.getCustomerQueryList("cash", false, widget.token);

        print(customerdetailsresponse);
        final dynamic customerdetailsid = await API.indexOfList(
            customerdetailsresponse,
            widget.selectedcustomerid != null
                ? widget.selectedcustomerid
                : widget.userdetails["default_customer_id"]);
        print("Selected data");
        print(customerdetailsid);
        setState(() {
          imgdatabytes = logoimgBytes;
          imgrowdatabytes = logorowimgBytes;
          if (customerdetailsid == -1) {
            customerdetails = {};
          } else {
            customerdetails = {
              "id": customerdetailsresponse[customerdetailsid].id,
              "name": customerdetailsresponse[customerdetailsid].name,
              "phone": customerdetailsresponse[customerdetailsid].phone,
              "email": customerdetailsresponse[customerdetailsid].email,
              "location": customerdetailsresponse[customerdetailsid].location
            };

            try {
              customerContactList =
                  customerdetailsresponse[customerdetailsid].arr_contacts;
              selectedContact = customerContactList[0]["id"].toString();
            } catch (ex) {
              print(ex);
            }
          }
        });

        setState(() {
          selectedreceipttype = receipttype[0];
          imagebytes = logoimage;
          print(imgdatabytes);
          mainloading = false;
        });
      });
    } catch (ex) {}
  }

  String cash_amount = "0.00";
  String card_amount = "0.00";

  calculateReceivedAmount() {
    setState(() {
      receivedamountcontroller.text =
          (SimpleConvert.safeDouble(card_amount == "" ? "0.00" : card_amount) +
                  SimpleConvert.safeDouble(
                      cash_amount == "" ? "0.00" : cash_amount))
              .toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  //variables
  Map<String, dynamic> itemdetails = {};
  Map<String, dynamic> customerdetails = {};
  Map<String, dynamic> selectedunit = {};
  Map<String, dynamic> selectedsalesman = {};
  List<dynamic> array_units = [];
  bool loading = false;
  bool dialogueloading = false;
  bool mainloading = false;
  String password = '';
  bool _securePassword = true;
  // Uint8List? imgdatabytes;

  List<dynamic> receipttype = [
    {"type": "Cash", "code": "CH"},
    {"type": "Card", "code": "CA"},
    {"type": "Cash + Card", "code": "CC"},
    {"type": "Credit Sale", "code": "CR"},
  ];
  //removed select receipt type and set cash as default.
// {"type": "Select", "code": ""},

  Map<String, dynamic> selectedreceipttype = {};

  // calculateReceivedAmount() {
  //   setState(() {
  //     receivedamountcontroller.text =
  //         (SimpleConvert.safeDouble(cashcard_cash) +SimpleConvert.safeDouble(cashcard_card))
  //             .toStringAsFixed(2);
  //   });
  //   print("This is received total");
  //   print(receivedamountcontroller.text);
  // }

  bool barcodeswitch = true;
  String barcodeText = "";
  //  num total = 0.00;
  //   num totalafterdiscountpercentage = 0.00;
  //   print("Inside checking total before adding to cart");
  //   print(itemdetails);
  //   num totalafterdiscount = (SimpleConvert.safeDouble(itemdetails["rate"].toString()) *
  //          SimpleConvert.safeDouble(itemdetails["quantity"].toString())) -
  //      SimpleConvert.safeDouble(itemdetails["discount"].toString());
  //   print("The total after discount only");
  //   print(totalafterdiscount);
  //   if (SimpleConvert.safeDouble(itemdetails["discount_percentage"].toString()) == 0) {
  //     total = totalafterdiscount;
  //   } else {
  //     totalafterdiscountpercentage = (totalafterdiscount *
  //            SimpleConvert.safeDouble(itemdetails["discount_percentage"].toString())) /
  //         100;
  //     total = totalafterdiscount - totalafterdiscountpercentage;
  //   }
  // num totalafterdiscountpercentage =  (totalafterdiscount *
  //        SimpleConvert.safeDouble(itemdetails["discount_percentage"].toString())) /
  //     100;
  // {id: 1052, part_number: ABC-1001, description: Test Item 01, brand_id: 2, brand_name: SPRAY, rate: 200.00, quantity: 1, warehouse_id: 5, unit_name: null, unit_id: null, arr_units: [{id: 52, unit_name: PCS, unit_factor: 1.000000, unit_price: 200.00}], tax_code: 5, discount: 20, available_qty: 973.000000000,}
  // num beforeselect_total = 0.00;
  // print("The total after discount percentage");
  // print(total);

  Future<Map<String, dynamic>> checkTotal(
      Map<String, dynamic> itemdetails) async {
    double total = 0.00;
    double totalafterdiscountpercentage = 0.00;
    if (itemdetails["quantity"] == "" || itemdetails["quantity"] == null) {
      itemdetails["quantity"] = "0";
    }
    print("called checkTotal : Inside checking total before adding to cart");
    print(itemdetails);

    double totalbeforediscount =
        (SimpleConvert.safeDouble(itemdetails["rate"].toString()) *
            SimpleConvert.safeDouble(itemdetails["quantity"].toString()));
    print("The total after discount only");
    print(totalbeforediscount);

    if (SimpleConvert.safeDouble(
            itemdetails["discount_percentage"].toString()) ==
        0) {
      total = totalbeforediscount -
          SimpleConvert.safeDouble(itemdetails["discount"].toString());
    } else {
      totalafterdiscountpercentage = (totalbeforediscount *
              SimpleConvert.safeDouble(
                  itemdetails["discount_percentage"].toString())) /
          100;
      total = totalbeforediscount -
          totalafterdiscountpercentage -
          SimpleConvert.safeDouble(itemdetails["discount"].toString());
    }
    // num totalafterdiscountpercentage =  (totalafterdiscount *
    //        SimpleConvert.safeDouble(itemdetails["discount_percentage"].toString())) /
    //     100;
    // {id: 1052, part_number: ABC-1001, description: Test Item 01, brand_id: 2, brand_name: SPRAY, rate: 200.00, quantity: 1, warehouse_id: 5, unit_name: null, unit_id: null, arr_units: [{id: 52, unit_name: PCS, unit_factor: 1.000000, unit_price: 200.00}], tax_code: 5, discount: 20, available_qty: 973.000000000,}
    // num beforeselect_total = 0.00;
    print("The total after discount percentage");
    print(total);
    // print(totalafterdiscountpercentage);
    // total = tot
    return {
      "total": SimpleConvert.safeDouble(total.toString()).toStringAsFixed(6),
      "discountvalue":
          SimpleConvert.safeDouble(itemdetails["discount"].toString())
              .toStringAsFixed(6),
      "discountpercentagevalue":
          SimpleConvert.safeDouble(totalafterdiscountpercentage.toString())
              .toStringAsFixed(6),
      "subtotalafterdiscount":
          ((SimpleConvert.safeDouble(total.toString()) * 100) /
                  (100 +
                      SimpleConvert.safeDouble(SimpleConvert.safeDouble(
                              itemdetails["tax_code"].toString())
                          .toStringAsFixed(1))))
              .toStringAsFixed(6),
      "vatafterdiscount": (SimpleConvert.safeDouble(total.toString()) -
              ((SimpleConvert.safeDouble(total.toString()) * 100) /
                  (100 +
                      SimpleConvert.safeDouble(SimpleConvert.safeDouble(
                              itemdetails["tax_code"].toString())
                          .toStringAsFixed(1)))))
          .toStringAsFixed(6)
    };
  }

  showHide() {
    setState(() {
      _securePassword = !_securePassword;
    });
  }

  //widget to show icons
  Widget iconDisplay(bool data) {
    if (data) {
      return const Icon(
        Icons.visibility_off,
        size: 14,
        color: Color.fromRGBO(181, 184, 203, 1),
      );
    } else {
      return const Icon(
        Icons.visibility,
        size: 14,
        color: Color.fromRGBO(181, 184, 203, 1),
      );
    }
  }

  addProducttoTable(CartModel model) async {
    double rate = SimpleConvert.safeDouble(itemdetails["rate"].toString());
    double qty = SimpleConvert.safeDouble(itemdetails["quantity"].toString());
    if (rate > 0 && qty > 0) {
      bool hasQtyInStock = model.hasQtyInStock(
          itemdetails["id"],
          model.cart,
          itemdetails["quantity"].toString(),
          itemdetails["available_qty"].toString(),
          itemdetails["inventory_item_type"].toString());
      if (allowNegativeQty || hasQtyInStock) {
        ///
        ///
        /*
      if (!hasQtyInStock) {
        String productDesc = itemdetails["description"].toString();
        Get.snackbar(
            maxWidth: MediaQuery.of(context).size.width / 4,
            "Failed",
            "$productDesc out of stock.",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      } */
        if (model.checkItems(itemdetails["id"], model.cart)) {
          var product_id = itemdetails["id"];
          model.cart.forEach((element) {
            if (element.id == product_id) {
              double quantity = SimpleConvert.safeDouble(element.quantity);

              double newQty =
                  SimpleConvert.safeDouble(itemdetails["quantity"].toString());
              quantity += newQty;
              element.quantity = quantity.toInt().toString();
            }
            model.calculateTotalRate();
          });
        } else {
          final dynamic checkcalculateddata = await checkTotal(itemdetails);
          print("The calculated data");
          print(checkcalculateddata);
          model.addProduct(
            ItemSchema(
              id: itemdetails["id"],
              partnumber: itemdetails["part_number"],
              description: itemdetails["description"],
              brandid: itemdetails["brand_id"],
              brandname: itemdetails["brand_name"],
              rate: itemdetails["rate"],
              quantity: itemdetails["quantity"],
              warehouseid: itemdetails["warehouse_id"],
              unit_name: selectedunit["unit_name"].toString(),
              unit_id: selectedunit["id"].toString(),
              arr_units: itemdetails["arr_units"],
              tax_code: itemdetails["tax_code"],
              discount:
                  SimpleConvert.safeDouble(itemdetails["discount"].toString()),
              availableqty: itemdetails["available_qty"],
              discount_percentage: SimpleConvert.safeDouble(
                  itemdetails["discount_percentage"].toString()),
              discountvalue: SimpleConvert.safeDouble(
                  checkcalculateddata["discountvalue"].toString()),
              discountpercentagevalue: SimpleConvert.safeDouble(
                  checkcalculateddata["discountpercentagevalue"].toString()),
              totalafterdiscount: SimpleConvert.safeDouble(
                  checkcalculateddata["total"].toString()),
              vatafterdiscount: SimpleConvert.safeDouble(
                  checkcalculateddata["vatafterdiscount"].toString()),
              subtotalafterdiscount: SimpleConvert.safeDouble(
                  checkcalculateddata["subtotalafterdiscount"].toString()),
              barcode: itemdetails["bar_code"].toString(),
              inventory_item_type:
                  itemdetails["inventory_item_type"].toString(),
            ),
          );
          model.calculateTotalRate();

          focusnode.requestFocus();
          itemFocusnode.requestFocus();
          if (model.LineDiscountEnabled) {
            discountController.text = model.footer_discount.toString();
          }
          setState(() {
            itemdetails = {};
          });
        }
        setState(() {
          itemdetails = {};
        });
      } else {
        Get.snackbar(
            maxWidth: MediaQuery.of(context).size.width / 4,
            "Failed",
            "Product out of stock",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } else {
      Get.snackbar(
          maxWidth: MediaQuery.of(context).size.width / 4,
          "Failed",
          "Total must be greater than zero.",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  clearData() {
    itemdetails = {};
    customerdetails = {};
  }

  Future<bool> _onWillPop(CartModel model) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), //<-- SEE HERE
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () {
                  ClearAllData(model);
                  model = CartModel();
                  clearData();
                  pushWidgetWhileRemove(context: context, newPage: dashboard());
                },
                // <-- SEE HERE
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CartModel>(builder: (context, child, model) {
      return KeyboardSizeProvider(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: API.background,
            body: mainloading
                ? const LoadingScreen()
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            border: Border.all(color: API.bordercolor)),
                        child: Column(
                          children: [
                            Container(
                              height: 130,
                              width: MediaQuery.of(context).size.width,
                              // color: Colors.red,
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            _onWillPop(model);
                                          },
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            color: Colors.red,
                                          )),
                                      IconButton(
                                          onPressed: () async {
                                            var result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddCustomer(
                                                        usbdevice:
                                                            widget.usbdevice,
                                                        userdetails:
                                                            widget.userdetails,
                                                        type: AddCustomer
                                                            .TYPE_FROM_INVOICE,
                                                        token: widget.token),
                                              ),
                                            );
                                            if (result != null) {
                                              setState(() {
                                                customerdetails = result;
                                                customerContactList =
                                                    result["contact"];
                                                if (customerContactList !=
                                                        null &&
                                                    customerContactList.length >
                                                        0) {
                                                  selectedContact =
                                                      customerContactList[0]
                                                              ["id"]
                                                          .toString();
                                                }
                                              });
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.green,
                                          )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 120,
                                    width: 2,
                                    child: VerticalDivider(
                                      color: API.bordercolor,
                                    ),
                                  ),
                                  customerdetails.isEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 40),
                                          child: SizedBox(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.8,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Choose customer"
                                                            .toUpperCase(),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 48,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.5,
                                                    child: TypeAheadField(
                                                        textFieldConfiguration:
                                                            TextFieldConfiguration(
                                                          style: TextStyle(
                                                              color:
                                                                  API.textcolor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                          decoration:
                                                              InputDecoration(
                                                                  filled: true,
                                                                  fillColor:
                                                                      const Color.fromRGBO(
                                                                          248,
                                                                          248,
                                                                          253,
                                                                          1),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: API
                                                                          .bordercolor,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Colors
                                                                          .green,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  hintStyle: const TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      color: Color.fromRGBO(
                                                                          181,
                                                                          184,
                                                                          203,
                                                                          1),
                                                                      fontWeight: FontWeight
                                                                          .w500,
                                                                      fontSize:
                                                                          14),
                                                                  contentPadding:
                                                                      const EdgeInsets.fromLTRB(
                                                                          10.0,
                                                                          10.0,
                                                                          10.0,
                                                                          10.0),
                                                                  // ignore: unnecessary_null_comparison
                                                                  hintText:
                                                                      'Enter Customer',
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(4.0))),
                                                        ),
                                                        suggestionsCallback:
                                                            (value) async {
                                                          if (value == null) {
                                                            return await API
                                                                .getCustomerQueryList(
                                                                    "",
                                                                    false,
                                                                    widget
                                                                        .token);
                                                          } else {
                                                            return await API
                                                                .getCustomerQueryList(
                                                                    value,
                                                                    false,
                                                                    widget
                                                                        .token);
                                                          }
                                                        },
                                                        itemBuilder: (context,
                                                            CustomerSchema?
                                                                itemslist) {
                                                          final listdata =
                                                              itemslist;
                                                          return ListTile(
                                                            title: Text(
                                                              "${listdata!.name.toUpperCase()} [ ${listdata.phone.toUpperCase()} ] ",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: false,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  color: API
                                                                      .textcolor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14),
                                                            ),
                                                          );
                                                        },
                                                        onSuggestionSelected:
                                                            (CustomerSchema?
                                                                itemslist) {
                                                          final data = {
                                                            'id': itemslist!.id,
                                                            'name':
                                                                itemslist.name,
                                                            'phone':
                                                                itemslist.phone,
                                                            "email":
                                                                itemslist.email,
                                                            "location":
                                                                itemslist
                                                                    .location,
                                                          };
                                                          setState(() {
                                                            selectedContact =
                                                                null;
                                                            customerdetails =
                                                                data;
                                                            customerContactList =
                                                                itemslist
                                                                    .arr_contacts;
                                                            if (customerContactList
                                                                    .length >
                                                                0) {
                                                              selectedContact =
                                                                  customerContactList[
                                                                              0]
                                                                          ["id"]
                                                                      .toString();
                                                            }
                                                            print(
                                                                customerContactList);
                                                            focusnode
                                                                .requestFocus();
                                                          });
                                                          print(
                                                              customerdetails);
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          // color: Colors.brown,
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    customerdetails = {};
                                                    customerContactList = [];
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 1,
                                                      horizontal: 7),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .businessTime,
                                                            color: Colors.black,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          customerdetails[
                                                                  "name"]
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: API
                                                              .textdetailstyle(),
                                                        ),
                                                      ),
                                                      const FaIcon(
                                                        FontAwesomeIcons.edit,
                                                        color: Colors.green,
                                                        size: 15,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1,
                                                        horizontal: 7),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton<dynamic>(
                                                    isExpanded: true,
                                                    icon: Icon(
                                                        Icons.contact_mail),
                                                    value: customerContactList
                                                            .isEmpty
                                                        ? null
                                                        : (selectedContact ==
                                                                null)
                                                            ? null
                                                            : selectedContact
                                                                .toString(),
                                                    hint: const Text(
                                                      'Select Contact',
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              135, 141, 186, 1),
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14),
                                                    ),
                                                    isDense: true,
                                                    onChanged: (data) async {
                                                      print(data);
                                                      selectedContact =
                                                          data.toString();
                                                      customerContactList
                                                          .forEach((element) {
                                                        if (element["id"] ==
                                                            selectedContact) {
                                                          selectedCustomerContact = CustomerContact(
                                                              id: element["id"]
                                                                  .toString(),
                                                              person_name: element[
                                                                      "person_name"]
                                                                  .toString(),
                                                              contact_mobile_no:
                                                                  element["person_name"]
                                                                      .toString(),
                                                              latitude: element[
                                                                      "person_name"]
                                                                  .toString(),
                                                              longitude: element[
                                                                      "person_name"]
                                                                  .toString());
                                                        }
                                                      });
                                                      setState(() {
                                                        print(
                                                            "Selected contact ");
                                                      });
                                                    },
                                                    items: customerContactList
                                                        .map((value) {
                                                      return DropdownMenuItem<
                                                              dynamic>(
                                                          value: value["id"]
                                                              .toString(),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            height: 20.0,
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    2.0,
                                                                    2.0,
                                                                    2.0,
                                                                    0.0),
                                                            child: Container(
                                                              child: Text(
                                                                value['person_name']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    color: API
                                                                        .textcolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          ));
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1,
                                                        horizontal: 7),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      child: const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5),
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .squarePhone,
                                                          color: Colors.black,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            customerdetails[
                                                                    "phone"]
                                                                .toString()
                                                                .toUpperCase(),
                                                            style: API
                                                                .textdetailstyle(),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1,
                                                        horizontal: 7),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      child: const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5),
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .locationDot,
                                                          color: Colors.black,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            customerdetails[
                                                                    "location"]
                                                                .toString()
                                                                .toUpperCase(),
                                                            style: API
                                                                .textdetailstyle(),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    // FaIcon(
                                                    //   FontAwesomeIcons.edit,
                                                    //   color: Colors.green,
                                                    //   size: 18,
                                                    // )
                                                  ],
                                                ),
                                              ),
                                              // Padding(
                                              //   padding: const EdgeInsets.only(
                                              //       left: 7, right: 7, top: 0),
                                              //   child: Row(
                                              //     mainAxisSize:
                                              //         MainAxisSize.max,
                                              //     mainAxisAlignment:
                                              //         MainAxisAlignment
                                              //             .spaceBetween,
                                              //     children: [
                                              //       Text(
                                              //           "Delivery at Location"),
                                              //       Switch(
                                              //           value: homeDelivery,
                                              //           onChanged: (value) {
                                              //             setState(() {
                                              //               homeDelivery =
                                              //                   value;
                                              //             });
                                              //           }),
                                              //     ],
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                  SizedBox(
                                    height: 120,
                                    width: 2,
                                    child: VerticalDivider(
                                      color: API.bordercolor,
                                    ),
                                  ),
                                  Expanded(
                                      child: Container(
                                    // color: Colors.blue,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                // color: Colors.red,
                                                width: 80,
                                                height: 80,
                                                // color: Colors.green,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  imageUrl: widget.userdetails[
                                                      "branchlink"],
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              downloadProgress) =>
                                                          Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            backgroundColor:
                                                                Colors.red,
                                                            strokeWidth: 1,
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                                // Image.asset(
                                                //                                             "assets/images/logo1.png",
                                                //                                             height: MediaQuery.of(context)
                                                //                                                     .size
                                                //                                                     .height /
                                                //                                                 6,
                                                //                                             width: 70,
                                                //                                           ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                              child: Container(
                                            // color: Colors.yellow,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.userdetails[
                                                              "company_name"]
                                                          .toUpperCase(),
                                                      style:
                                                          API.textdetailstyle(),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.userdetails[
                                                              "billing_address"]
                                                          .toString()
                                                          .toUpperCase(),
                                                      overflow:
                                                          TextOverflow.visible,
                                                      style:
                                                          API.textdetailstyle(),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.userdetails[
                                                              "genral_phno"]
                                                          .toString(),
                                                      style:
                                                          API.textdetailstyle(),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                          Container(
                                            // color: Colors.red,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                7,
                                            height: 80,
                                            // color: Colors.green,
                                            child: Image.asset(
                                                "assets/images/logo-b.png"),
                                            // Image.asset(
                                            //                                             "assets/images/logo1.png",
                                            //                                             height: MediaQuery.of(context)
                                            //                                                     .size
                                            //                                                     .height /
                                            //                                                 6,
                                            //                                             width: 70,
                                            //                                           ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                            Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width,
                              color: API.bordercolor,
                            ),
                            Container(
                              // height: MediaQuery.of(context)
                              //         .size
                              //         .height /
                              //     9,
                              height: 60,
                              width: double.maxFinite,
                              color: API.tilecolor,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: itemdetails.isEmpty
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.spaceAround,
                                children: [
                                  /*
                                  Column(
                                    children: [
                                     
                                      Switch(
                                        onChanged: (val) {
                                          setState(() {
                                            barcodeswitch = val;
                                            itemdetails = {};
                                          });
                                        },
                                        value: barcodeswitch,
                                        activeColor: Colors.green,
                                        activeTrackColor: Colors.white,
                                        inactiveThumbColor: Colors.redAccent,
                                        inactiveTrackColor: Colors.red,
                                      ),
                                      Text(
                                        barcodeswitch ? "Barcode" : "Search",
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ],
                                  ), */
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Item Name".toUpperCase(),
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat'),
                                          ),
                                        ],
                                      ),
                                      itemdetails.isNotEmpty
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.8,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                  // border:
                                                  color: const Color.fromRGBO(
                                                      248, 248, 253, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  border: Border.all(
                                                      color: Colors.green,
                                                      width: 1.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20.0, 5.0, 20.0, 5.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4.7,
                                                      child: Text(
                                                        itemdetails['bar_code']
                                                                .toString() +
                                                            " [ " +
                                                            itemdetails[
                                                                "description"] +
                                                            " ] "
                                                                .toString()
                                                                .toUpperCase(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color:
                                                                API.textcolor,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : barcodeswitch
                                              ? Container(
                                                  height: 44,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: Focus(
                                                    child: TextField(
                                                      controller:
                                                          barcodeController,
                                                      focusNode: focusnode,
                                                      autofocus: true,
                                                      style: TextStyle(
                                                          color: API.textcolor,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      decoration:
                                                          InputDecoration(
                                                              filled: true,
                                                              fillColor: const Color.fromRGBO(
                                                                  248,
                                                                  248,
                                                                  253,
                                                                  1),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: API
                                                                      .bordercolor,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                                borderSide:
                                                                    const BorderSide(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              hintStyle: const TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  color: Color.fromRGBO(
                                                                      181,
                                                                      184,
                                                                      203,
                                                                      1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14),
                                                              contentPadding:
                                                                  const EdgeInsets.fromLTRB(
                                                                      10.0,
                                                                      10.0,
                                                                      10.0,
                                                                      10.0),
                                                              // ignore: unnecessary_null_comparison
                                                              hintText:
                                                                  'Enter Items Name',
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(4.0))),
                                                      onChanged: (val) async {
                                                        print(
                                                            "This is the barcode section");
                                                        print(val);
                                                        if (val.isNotEmpty &&
                                                            val.length >= 2) {
                                                          final List<dynamic>
                                                              searchresponse =
                                                              await API.getItemsQueryList(
                                                                  "",
                                                                  val,
                                                                  userWareHouseId,
                                                                  widget.token,
                                                                  API.DISPLAY_TYPE_ALL_PROUDCT);
                                                          print("Thi is resp");
                                                          print(searchresponse
                                                              .length);
                                                          if (searchresponse
                                                              .isEmpty) {
                                                            // setState(() {
                                                            //   itemdetails = {};
                                                            // });
                                                            // Get.snackbar(
                                                            //     "Failed",
                                                            //     "No Items Found",
                                                            //     backgroundColor:
                                                            //         Colors.red,
                                                            //     colorText: Colors.white);
                                                          } else {
                                                            print(
                                                                "This is search response");
                                                            print(
                                                                searchresponse);
                                                            final data = {
                                                              'id':
                                                                  searchresponse[
                                                                          0]!
                                                                      .id,
                                                              'part_number':
                                                                  searchresponse[
                                                                          0]
                                                                      .partnumber,
                                                              'description':
                                                                  searchresponse[
                                                                          0]
                                                                      .description,
                                                              "brand_id":
                                                                  searchresponse[
                                                                          0]
                                                                      .brandid,
                                                              "brand_name":
                                                                  searchresponse[
                                                                          0]
                                                                      .brandname,
                                                              "rate":
                                                                  searchresponse[
                                                                          0]
                                                                      .rate,
                                                              "quantity":
                                                                  searchresponse[
                                                                          0]
                                                                      .quantity,
                                                              "warehouse_id":
                                                                  searchresponse[
                                                                          0]
                                                                      .warehouseid,
                                                              "unit_name":
                                                                  searchresponse[
                                                                          0]
                                                                      .unit_name,
                                                              "unit_id":
                                                                  searchresponse[
                                                                          0]
                                                                      .unit_id,
                                                              "arr_units":
                                                                  searchresponse[
                                                                          0]
                                                                      .arr_units,
                                                              "tax_code":
                                                                  searchresponse[
                                                                          0]
                                                                      .tax_code,
                                                              "discount":
                                                                  searchresponse[
                                                                          0]
                                                                      .discount,
                                                              "available_qty":
                                                                  searchresponse[
                                                                          0]
                                                                      .availableqty,
                                                              "discount_percentage":
                                                                  searchresponse[
                                                                          0]
                                                                      .discount_percentage,
                                                              "discountvalue":
                                                                  searchresponse[
                                                                          0]
                                                                      .discountvalue,
                                                              "discountpercentagevalue":
                                                                  searchresponse[
                                                                          0]
                                                                      .discountpercentagevalue,
                                                              "totalafterdiscount":
                                                                  searchresponse[
                                                                          0]
                                                                      .totalafterdiscount,
                                                              "vatafterdiscount":
                                                                  searchresponse[
                                                                          0]
                                                                      .vatafterdiscount,
                                                              "subtotalafterdiscount":
                                                                  searchresponse[
                                                                          0]
                                                                      .subtotalafterdiscount,
                                                              "bar_code":
                                                                  searchresponse[
                                                                          0]
                                                                      .barcode
                                                            };
                                                            print(data);
                                                            setState(() {
                                                              itemdetails =
                                                                  data;
                                                              selectedunit =
                                                                  searchresponse[
                                                                          0]
                                                                      .arr_units[0];
                                                              array_units =
                                                                  searchresponse[
                                                                          0]
                                                                      .arr_units;
                                                              // focusnode
                                                              //     .unfocus();
                                                              qtyfocusnode
                                                                  .requestFocus();
                                                            });

                                                            addProducttoTable(
                                                                model);
                                                            barcodeController
                                                                .clear();
                                                            print(itemdetails);
                                                            focusnode
                                                                .requestFocus();
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height: 44,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TypeAheadField(
                                                      textFieldConfiguration:
                                                          TextFieldConfiguration(
                                                        autofocus: true,
                                                        focusNode:
                                                            itemFocusnode,
                                                        style: TextStyle(
                                                            color:
                                                                API.textcolor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                        decoration:
                                                            InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    const Color.fromRGBO(
                                                                        248,
                                                                        248,
                                                                        253,
                                                                        1),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: API
                                                                        .bordercolor,
                                                                    width: 1.0,
                                                                  ),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                    width: 1.0,
                                                                  ),
                                                                ),
                                                                hintStyle: const TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    color: Color.fromRGBO(
                                                                        181,
                                                                        184,
                                                                        203,
                                                                        1),
                                                                    fontWeight: FontWeight
                                                                        .w500,
                                                                    fontSize:
                                                                        14),
                                                                contentPadding:
                                                                    const EdgeInsets.fromLTRB(
                                                                        10.0,
                                                                        10.0,
                                                                        10.0,
                                                                        10.0),
                                                                // ignore: unnecessary_null_comparison
                                                                hintText:
                                                                    'Enter Item Name',
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(4.0))),
                                                      ),
                                                      suggestionsCallback:
                                                          (value) async {
                                                        if (value == null) {
                                                          return await API
                                                              .getItemsQueryList(
                                                                  "",
                                                                  "",
                                                                  userWareHouseId,
                                                                  widget.token,
                                                                  API.DISPLAY_TYPE_ALL_PROUDCT);
                                                        } else {
                                                          return await API
                                                              .getItemsQueryList(
                                                                  value,
                                                                  "",
                                                                  userWareHouseId,
                                                                  widget.token,
                                                                  API.DISPLAY_TYPE_ALL_PROUDCT);
                                                        }
                                                      },
                                                      itemBuilder: (context,
                                                          ItemSchema?
                                                              itemslist) {
                                                        final listdata =
                                                            itemslist;
                                                        return ListTile(
                                                          title: Text(
                                                            "${listdata!.barcode.toUpperCase()} [ ${listdata.description.toUpperCase()} ]  [ ${listdata.availableqty.isEmpty ? "" : SimpleConvert.safeDouble(listdata.availableqty).toString().toUpperCase()} ] ",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            softWrap: false,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                color: API
                                                                    .textcolor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14),
                                                          ),
                                                        );
                                                      },
                                                      onSuggestionSelected:
                                                          (ItemSchema?
                                                              itemslist) {
                                                        final data = {
                                                          'id': itemslist!.id,
                                                          'part_number':
                                                              itemslist
                                                                  .partnumber,
                                                          'description':
                                                              itemslist
                                                                  .description,
                                                          "brand_id":
                                                              itemslist.brandid,
                                                          "brand_name":
                                                              itemslist
                                                                  .brandname,
                                                          "rate":
                                                              itemslist.rate,
                                                          "quantity": itemslist
                                                              .quantity,
                                                          "warehouse_id":
                                                              itemslist
                                                                  .warehouseid,
                                                          "unit_name": itemslist
                                                              .unit_name,
                                                          "unit_id":
                                                              itemslist.unit_id,
                                                          "arr_units": itemslist
                                                              .arr_units,
                                                          "tax_code": itemslist
                                                              .tax_code,
                                                          "discount": itemslist
                                                              .discount,
                                                          "available_qty":
                                                              itemslist
                                                                  .availableqty,
                                                          "discount_percentage":
                                                              itemslist
                                                                  .discount_percentage,
                                                          "discountvalue":
                                                              itemslist
                                                                  .discountvalue,
                                                          "discountpercentagevalue":
                                                              itemslist
                                                                  .discountpercentagevalue,
                                                          "totalafterdiscount":
                                                              itemslist
                                                                  .totalafterdiscount,
                                                          "vatafterdiscount":
                                                              itemslist
                                                                  .vatafterdiscount,
                                                          "subtotalafterdiscount":
                                                              itemslist
                                                                  .subtotalafterdiscount,
                                                          "bar_code":
                                                              itemslist.barcode,
                                                          "inventory_item_type":
                                                              itemslist
                                                                  .inventory_item_type
                                                        };
                                                        setState(() {
                                                          itemdetails = data;
                                                          selectedunit =
                                                              itemslist
                                                                  .arr_units[0];
                                                          array_units =
                                                              itemslist
                                                                  .arr_units;
                                                          qtyfocusnode
                                                              .requestFocus();
                                                        });
                                                        print(itemdetails);
                                                        print(selectedunit);
                                                      }),
                                                ),
                                    ],
                                  ),
                                  itemdetails.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Rate".toUpperCase(),
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              height: 44,
                                              // color: Colors.red,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                initialValue:
                                                    itemdetails["rate"],
                                                style: TextStyle(
                                                    color: API.textcolor,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        const Color.fromRGBO(
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
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.green,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    hintStyle: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Color.fromRGBO(
                                                            181, 184, 203, 1),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                    contentPadding:
                                                        const EdgeInsets.fromLTRB(
                                                            10.0,
                                                            10.0,
                                                            10.0,
                                                            10.0),
                                                    // ignore: unnecessary_null_comparison
                                                    hintText: 'Rate',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0))),
                                                onChanged: (val) {
                                                  setState(() {
                                                    itemdetails["rate"] = val;
                                                  });
                                                  print(itemdetails);
                                                },
                                              ),
                                            )
                                          ],
                                        )
                                      : const SizedBox(),
                                  itemdetails.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Quantity".toUpperCase(),
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                            Focus(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    13,
                                                height: 44,
                                                // color: Colors.red,
                                                child: CallbackShortcuts(
                                                  bindings: {
                                                    const SingleActivator(
                                                        LogicalKeyboardKey
                                                            .enter): () =>
                                                        addProducttoTable(
                                                            model),
                                                  },
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    focusNode: qtyfocusnode,
                                                    initialValue:
                                                        itemdetails["quantity"],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor:
                                                            const Color.fromRGBO(
                                                                248, 248, 253, 1),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                API.bordercolor,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.green,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        hintStyle: const TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Color.fromRGBO(
                                                                181,
                                                                184,
                                                                203,
                                                                1),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            const EdgeInsets.fromLTRB(
                                                                10.0,
                                                                10.0,
                                                                10.0,
                                                                10.0),
                                                        // ignore: unnecessary_null_comparison
                                                        hintText: 'QTY',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    4.0))),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        itemdetails[
                                                            "quantity"] = val;
                                                      });
                                                      print(itemdetails);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : const SizedBox(),
                                  itemdetails.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Unit".toUpperCase(),
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              height: 44,
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        const Color.fromRGBO(
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
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.green,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    hintStyle: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Color.fromRGBO(
                                                            181, 184, 203, 1),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                    contentPadding:
                                                        const EdgeInsets.fromLTRB(
                                                            10.0,
                                                            10.0,
                                                            10.0,
                                                            10.0),
                                                    // ignore: unnecessary_null_comparison
                                                    hintText: 'Unit',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0))),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton<dynamic>(
                                                    isExpanded: true,
                                                    dropdownColor: Colors.white,
                                                    hint: const Text(
                                                      'Choose Unit',
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              135, 141, 186, 1),
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14),
                                                    ),
                                                    value: selectedunit,
                                                    isDense: true,
                                                    onChanged: (data) async {
                                                      setState(() {
                                                        selectedunit = data;
                                                      });
                                                    },
                                                    items: array_units
                                                        .map((value) {
                                                      return DropdownMenuItem<
                                                              dynamic>(
                                                          value: value,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            height: 20.0,
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    2.0,
                                                                    2.0,
                                                                    2.0,
                                                                    0.0),
                                                            child: Container(
                                                              child: Text(
                                                                value['unit_name']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    color: API
                                                                        .textcolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          ));
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  itemdetails.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              "Discount",
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Montserrat'),
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    13,
                                                height: 44,
                                                // color: Colors.red,
                                                child: CallbackShortcuts(
                                                  bindings: {
                                                    const SingleActivator(
                                                        LogicalKeyboardKey
                                                            .enter): () =>
                                                        LineAddItems(model)
                                                  },
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    focusNode:
                                                        linediscountfocusnode,
                                                    initialValue:
                                                        itemdetails["discount"]
                                                            .toString(),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                        color: API.textcolor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor:
                                                            const Color.fromRGBO(
                                                                248, 248, 253, 1),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                API.bordercolor,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.green,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        hintStyle: const TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Color.fromRGBO(
                                                                181,
                                                                184,
                                                                203,
                                                                1),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            const EdgeInsets.fromLTRB(
                                                                10.0,
                                                                10.0,
                                                                10.0,
                                                                10.0),
                                                        // ignore: unnecessary_null_comparison
                                                        hintText: 'Discount',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    4.0))),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        itemdetails[
                                                                "discount"] =
                                                            SimpleConvert
                                                                .safeDouble(val
                                                                    .toString());
                                                        if (SimpleConvert
                                                                .safeDouble(val
                                                                    .toString()) >
                                                            0) {
                                                          model.LineDiscountEnabled =
                                                              true;
                                                          true;
                                                        }
                                                      });
                                                      print(itemdetails);
                                                    },
                                                  ),
                                                ))
                                          ],
                                        )
                                      : const SizedBox(),
                                  itemdetails.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Total".toUpperCase(),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      13,
                                                  height: 44,
                                                  // color: Colors.red,
                                                  child: Container(
                                                      child: InputDecorator(
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor:
                                                            const Color.fromRGBO(
                                                                248, 248, 253, 1),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                API.bordercolor,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.green,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        hintStyle: const TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Color.fromRGBO(
                                                                181,
                                                                184,
                                                                203,
                                                                1),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            const EdgeInsets.fromLTRB(
                                                                10.0,
                                                                10.0,
                                                                10.0,
                                                                10.0),
                                                        // ignore: unnecessary_null_comparison
                                                        hintText: 'Percentage',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    4.0))),
                                                    child: FutureBuilder(
                                                        future: checkTotal(
                                                            itemdetails),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Center(
                                                              child: Row(
                                                                children: [
                                                                  const CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white,
                                                                    strokeWidth:
                                                                        1,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .done ||
                                                              snapshot.connectionState ==
                                                                  ConnectionState
                                                                      .active) {
                                                            if (snapshot
                                                                .hasError) {
                                                              return Center(
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .warning,
                                                                      color: Colors
                                                                          .yellow,
                                                                      size: 15,
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            } else if (snapshot
                                                                .hasData) {
                                                              dynamic datacal =
                                                                  snapshot.data;
                                                              return Text(
                                                                SimpleConvert.safeDouble(
                                                                        datacal["total"]
                                                                            .toString())
                                                                    .toStringAsFixed(
                                                                        2),
                                                                style: TextStyle(
                                                                    color: API
                                                                        .textcolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              );
                                                            } else {
                                                              return const SizedBox();
                                                            }
                                                          } else {
                                                            return const SizedBox();
                                                          }
                                                        }),
                                                  )))
                                            ])
                                      : const SizedBox(),
                                  itemdetails.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              itemdetails = {};
                                            });
                                          },
                                          icon: const FaIcon(
                                            FontAwesomeIcons.trash,
                                            size: 20,
                                            color: Colors.red,
                                          ))
                                      : const SizedBox(),
                                  itemdetails.isNotEmpty
                                      ? IconButton(
                                          onPressed: () async {
                                            LineAddItems(model);
                                          },
                                          icon: const FaIcon(
                                            FontAwesomeIcons.checkCircle,
                                            size: 20,
                                            color: Colors.white,
                                          ))
                                      : const SizedBox()
                                ],
                              ),
                            ),
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Container(
                                            // color: Colors.yellow,
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  // color: Colors.yellow,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 25,
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            5.5,
                                                        // color: Colors.red,
                                                        child: const Text(
                                                          "Item Code",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  'Montserrat'),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.8,
                                                        // color: Colors.blue,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            // Container(
                                                            //   width: MediaQuery.of(
                                                            //               context)
                                                            //           .size
                                                            //           .width /
                                                            //       1.8 /
                                                            //       7,
                                                            //   child: Text(
                                                            //     "Brand",
                                                            //     textAlign:
                                                            //         TextAlign
                                                            //             .start,
                                                            //     style: TextStyle(
                                                            //         color: Colors
                                                            //             .black,
                                                            //         fontSize:
                                                            //             12,
                                                            //         fontWeight:
                                                            //             FontWeight
                                                            //                 .w600,
                                                            //         fontFamily:
                                                            //             'Montserrat'),
                                                            //   ),
                                                            // ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Rate",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Qty",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Unit",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Amt",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Dis",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Total W/t VAT",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "VAT",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.8 /
                                                                  8,
                                                              child: const Text(
                                                                "Total",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  color: API.bordercolor,
                                                  height: 0.8,
                                                ),
                                                Expanded(
                                                  child: ListView.builder(
                                                      itemCount:
                                                          model.cart.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          height: 30,
                                                          // color: Colors.yellow,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                  width: 25,
                                                                  child: Center(
                                                                    child: Text(
                                                                      (index + 1)
                                                                              .toString() +
                                                                          " : ",
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontFamily:
                                                                              'Montserrat'),
                                                                    ),
                                                                  )),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    5.5,
                                                                // color: Colors.red,
                                                                child: Text(
                                                                  model
                                                                          .cart[
                                                                              index]
                                                                          .barcode
                                                                          .toUpperCase() +
                                                                      " / " +
                                                                      model
                                                                          .cart[
                                                                              index]
                                                                          .description
                                                                          .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.8,
                                                                // color:
                                                                // Colors.blue,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // Container(
                                                                    //   width: MediaQuery.of(context)
                                                                    //           .size
                                                                    //           .width /
                                                                    //       1.8 /
                                                                    //       7,
                                                                    //   // color: Colors
                                                                    //   //     .red,
                                                                    //   child:
                                                                    //       Text(
                                                                    //     model
                                                                    //         .cart[index]
                                                                    //         .brandname,
                                                                    //     textAlign:
                                                                    //         TextAlign.start,
                                                                    //     style: TextStyle(
                                                                    //         color: Colors
                                                                    //             .green,
                                                                    //         fontSize:
                                                                    //             11,
                                                                    //         fontWeight:
                                                                    //             FontWeight.w600,
                                                                    //         fontFamily: 'Montserrat'),
                                                                    //   ),
                                                                    // ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      // color: Colors
                                                                      //     .yellow,
                                                                      child:
                                                                          Text(
                                                                        model
                                                                            .cart[index]
                                                                            .rate,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      // color: Colors
                                                                      //     .red,
                                                                      child:
                                                                          Text(
                                                                        model
                                                                            .cart[index]
                                                                            .quantity,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      // color: Colors
                                                                      //     .yellow,
                                                                      child:
                                                                          Text(
                                                                        model
                                                                            .cart[index]
                                                                            .unit_name
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      child:
                                                                          Text(
                                                                        SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].rate) * SimpleConvert.safeDouble(model.cart[index].quantity)).toString())
                                                                            .toStringAsFixed(2),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      // color: Colors
                                                                      //     .red,
                                                                      child:
                                                                          Text(
                                                                        // (SimpleConvert.safeDouble(model.cart[index].discount.toString()) *
                                                                        //        SimpleConvert.safeDouble(model.cart[index].quantity.toString()))
                                                                        //     .toStringAsFixed(2),
                                                                        model
                                                                            .cart[index]
                                                                            .discountvalue
                                                                            .toStringAsFixed(2),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      child:
                                                                          Text(
                                                                        SimpleConvert.safeDouble(model.cart[index].subtotalafterdiscount.toString())
                                                                            .toStringAsFixed(2),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      // color: Colors
                                                                      //     .yellow,
                                                                      child:
                                                                          Text(
                                                                        //SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble(model.cart[index].quantity) *SimpleConvert.safeDouble(model.cart[index].rate)) - (SimpleConvert.safeDouble(model.cart[index].quantity) *SimpleConvert.safeDouble(model.cart[index].discount))).toString()) * (SimpleConvert.safeDouble(model.cart[index].tax_code))) / 100).toString())
                                                                        //     .toStringAsFixed(2)
                                                                        //SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].rate) *SimpleConvert.safeDouble(model.cart[index].quantity)).toString())) - ((SimpleConvert.safeDouble(model.cart[index].discount.toString()) *SimpleConvert.safeDouble(model.cart[index].quantity.toString())))).toString()) * 5) / 105).toString())
                                                                        //     .toStringAsFixed(2)

                                                                        // ((SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].quantity) *SimpleConvert.safeDouble(model.cart[index].rate)).toString()) *SimpleConvert.safeDouble(model.cart[index].tax_code)) /
                                                                        //         100)
                                                                        //     .toStringAsFixed(
                                                                        //         2),
                                                                        SimpleConvert.safeDouble(model.cart[index].vatafterdiscount.toString())
                                                                            .toStringAsFixed(2),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.8 /
                                                                          8,
                                                                      // color: Colors
                                                                      //     .red,
                                                                      child:
                                                                          Text(
                                                                        //SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].quantity) *SimpleConvert.safeDouble(model.cart[index].rate))
                                                                        //         .toString())
                                                                        //     .toStringAsFixed(
                                                                        //         2),
                                                                        //SimpleConvert.safeDouble(((SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].rate) *SimpleConvert.safeDouble(model.cart[index].quantity)).toString())) - ((SimpleConvert.safeDouble(model.cart[index].discount.toString()) *SimpleConvert.safeDouble(model.cart[index].quantity.toString())))).toString())
                                                                        //     .toStringAsFixed(2)
                                                                        // SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)) - (SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].discount))).toString())) + SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)) - (SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].discount))).toString()) * (SimpleConvert.safeDouble(model.cart[index].tax_code))) / 100).toString())).toString())
                                                                        //     .toStringAsFixed(2),
                                                                        SimpleConvert.safeDouble(model.cart[index].totalafterdiscount.toString())
                                                                            .toStringAsFixed(2),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      Container(
                                                                // color: Colors
                                                                //     .green,
                                                                child: Center(
                                                                  child:
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            model.removeProduct(model.cart[index].id);
                                                                            model.calculateTotalRate();
                                                                            if (model.LineDiscountEnabled) {
                                                                              discountController.text = model.footer_discount.toString();
                                                                            }
                                                                          },
                                                                          icon: const Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red)),
                                                                ),
                                                              ))
                                                            ],
                                                          ),
                                                        );

                                                        // ListTile(
                                                        //   leading: Container(
                                                        //     width: 30,
                                                        //     height: 40,
                                                        //     child: Center(
                                                        //       child: Text(
                                                        //         (index + 1)
                                                        //             .toString(),
                                                        //         style: TextStyle(
                                                        //             color: Colors
                                                        //                 .black,
                                                        //             fontSize: 14,
                                                        //             fontWeight:
                                                        //                 FontWeight
                                                        //                     .w600,
                                                        //             fontFamily:
                                                        //                 'Montserrat'),
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        //   title: Text(
                                                        //     model.cart[index]
                                                        //         .partnumber
                                                        //         .toUpperCase(),
                                                        //     textAlign:
                                                        //         TextAlign.start,
                                                        //     style: const TextStyle(
                                                        //         color:
                                                        //             Colors.black,
                                                        //         fontSize: 12,
                                                        //         fontWeight:
                                                        //             FontWeight
                                                        //                 .w500,
                                                        //         fontFamily:
                                                        //             'Montserrat'),
                                                        //   ),
                                                        //   subtitle: Text(
                                                        //     model.cart[index]
                                                        //         .description,
                                                        //     textAlign:
                                                        //         TextAlign.start,
                                                        //     style: const TextStyle(
                                                        //         color:
                                                        //             Colors.black,
                                                        //         fontSize: 11,
                                                        //         fontWeight:
                                                        //             FontWeight
                                                        //                 .w400,
                                                        //         fontFamily:
                                                        //             'Montserrat'),
                                                        //   ),
                                                        //   trailing: Container(
                                                        //     width: MediaQuery.of(
                                                        //                 context)
                                                        //             .size
                                                        //             .width /
                                                        //         1.8,
                                                        //     child: Row(
                                                        //       mainAxisAlignment:
                                                        //           MainAxisAlignment
                                                        //               .spaceAround,
                                                        //       children: [
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Brand",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     model
                                                        //                         .cart[index]
                                                        //                         .brandname,
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Rate",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     model
                                                        //                         .cart[index]
                                                        //                         .rate,
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Quantity",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     model
                                                        //                         .cart[index]
                                                        //                         .quantity,
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Unit",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     model
                                                        //                         .cart[index]
                                                        //                         .unit_name
                                                        //                         .toString(),
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Discount",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     (SimpleConvert.safeDouble(model.cart[index].discount.toString()) * SimpleConvert.safeDouble(model.cart[index].quantity.toString()))
                                                        //                         .toStringAsFixed(2),
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Vat",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)) - (SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].discount))).toString()) * (SimpleConvert.safeDouble(model.cart[index].tax_code))) / 100).toString())
                                                        //                         .toStringAsFixed(2)

                                                        //                     // ((SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)).toString()) * SimpleConvert.safeDouble(model.cart[index].tax_code)) /
                                                        //                     //         100)
                                                        //                     //     .toStringAsFixed(
                                                        //                     //         2),
                                                        //                     ,
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         Column(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .center,
                                                        //           crossAxisAlignment:
                                                        //               CrossAxisAlignment
                                                        //                   .start,
                                                        //           children: [
                                                        //             // Text(
                                                        //             //   "Total",
                                                        //             //   textAlign:
                                                        //             //       TextAlign
                                                        //             //           .start,
                                                        //             //   style: TextStyle(
                                                        //             //       color: Colors
                                                        //             //           .black,
                                                        //             //       fontSize:
                                                        //             //           12,
                                                        //             //       fontWeight:
                                                        //             //           FontWeight
                                                        //             //               .w600,
                                                        //             //       fontFamily:
                                                        //             //           'Montserrat'),
                                                        //             // ),
                                                        //             Padding(
                                                        //               padding: const EdgeInsets
                                                        //                       .symmetric(
                                                        //                   vertical:
                                                        //                       5),
                                                        //               child: Row(
                                                        //                 mainAxisAlignment:
                                                        //                     MainAxisAlignment
                                                        //                         .center,
                                                        //                 children: [
                                                        //                   Text(
                                                        //                     // SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate))
                                                        //                     //         .toString())
                                                        //                     //     .toStringAsFixed(
                                                        //                     //         2),
                                                        //                     SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)) - (SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].discount))).toString())) + SimpleConvert.safeDouble(((SimpleConvert.safeDouble(((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)) - (SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].discount))).toString()) * (SimpleConvert.safeDouble(model.cart[index].tax_code))) / 100).toString())).toString())
                                                        //                         .toStringAsFixed(2),
                                                        //                     textAlign:
                                                        //                         TextAlign.start,
                                                        //                     style: TextStyle(
                                                        //                         color: Colors.green,
                                                        //                         fontSize: 13,
                                                        //                         fontWeight: FontWeight.w600,
                                                        //                         fontFamily: 'Montserrat'),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             )
                                                        //           ],
                                                        //         ),
                                                        //         // Column(
                                                        //         //   mainAxisAlignment:
                                                        //         //       MainAxisAlignment
                                                        //         //           .center,
                                                        //         //   crossAxisAlignment:
                                                        //         //       CrossAxisAlignment
                                                        //         //           .start,
                                                        //         //   children: [
                                                        //         //     Text(
                                                        //         //       "Total",
                                                        //         //       textAlign:
                                                        //         //           TextAlign
                                                        //         //               .start,
                                                        //         //       style: TextStyle(
                                                        //         //           color: Colors
                                                        //         //               .black,
                                                        //         //           fontSize: 12,
                                                        //         //           fontWeight:
                                                        //         //               FontWeight
                                                        //         //                   .w600,
                                                        //         //           fontFamily:
                                                        //         //               'Montserrat'),
                                                        //         //     ),
                                                        //         //     Padding(
                                                        //         //       padding:
                                                        //         //           const EdgeInsets
                                                        //         //                   .symmetric(
                                                        //         //               vertical:
                                                        //         //                   5),
                                                        //         //       child: Row(
                                                        //         //         mainAxisAlignment:
                                                        //         //             MainAxisAlignment
                                                        //         //                 .center,
                                                        //         //         children: [
                                                        //         //           Text(
                                                        //         //             ((((SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)).toString()) * SimpleConvert.safeDouble(model.cart[index].tax_code)) / 100) +
                                                        //         //                         SimpleConvert.safeDouble((SimpleConvert.safeDouble(model.cart[index].quantity) * SimpleConvert.safeDouble(model.cart[index].rate)).toString())) +
                                                        //         //                     SimpleConvert.safeDouble(model.cart[index].discount))
                                                        //         //                 .toStringAsFixed(2),
                                                        //         //             textAlign:
                                                        //         //                 TextAlign
                                                        //         //                     .start,
                                                        //         //             style: TextStyle(
                                                        //         //                 color: Colors
                                                        //         //                     .green,
                                                        //         //                 fontSize:
                                                        //         //                     13,
                                                        //         //                 fontWeight:
                                                        //         //                     FontWeight
                                                        //         //                         .w600,
                                                        //         //                 fontFamily:
                                                        //         //                     'Montserrat'),
                                                        //         //           ),
                                                        //         //         ],
                                                        //         //       ),
                                                        //         //     )
                                                        //         //   ],
                                                        //         // ),
                                                        //         IconButton(
                                                        //             onPressed:
                                                        //                 () {
                                                        //               model.removeProduct(model
                                                        //                   .cart[
                                                        //                       index]
                                                        //                   .id);
                                                        //               model
                                                        //                   .calculateTotalRate();
                                                        //             },
                                                        //             icon: Icon(
                                                        //                 Icons
                                                        //                     .delete,
                                                        //                 color: Colors
                                                        //                     .red))
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        // );
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ))
                                        ],
                                      ),
                                    )),
                                    Container(
                                      height: 1,
                                      color: API.bordercolor,
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              8,
                                      width: MediaQuery.of(context).size.width,
                                      // color: Colors.yellow,
                                      child: loading
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.red,
                                                strokeWidth: 1,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        RawMaterialButton(
                                                          onPressed: () async {
                                                            final dynamic
                                                                result =
                                                                await API
                                                                    .scanQR();
                                                            print(result);
                                                            if (result ==
                                                                "-1") {
                                                              Get.snackbar(
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4,
                                                                  "Failed",
                                                                  "Please scan to search items",
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  colorText:
                                                                      Colors
                                                                          .white);
                                                            } else {
                                                              print(
                                                                  "This is the result");
                                                              print(result);
                                                              final dynamic
                                                                  searchresponse =
                                                                  await API.getItemsQueryList(
                                                                      "",
                                                                      result,
                                                                      userWareHouseId,
                                                                      widget
                                                                          .token,
                                                                      API.DISPLAY_TYPE_ALL_PROUDCT);
                                                              print(
                                                                  "Thi is resp");
                                                              print(
                                                                  searchresponse);
                                                              if (searchresponse
                                                                      .length ==
                                                                  0) {
                                                                Get.snackbar(
                                                                    maxWidth: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        4,
                                                                    "Failed",
                                                                    "No Items Found",
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    colorText:
                                                                        Colors
                                                                            .white);
                                                              } else {
                                                                print(
                                                                    "This is search response");
                                                                print(
                                                                    searchresponse);
                                                                final data = {
                                                                  'id':
                                                                      searchresponse[
                                                                              0]!
                                                                          .id,
                                                                  'part_number':
                                                                      searchresponse[
                                                                              0]
                                                                          .partnumber,
                                                                  'description':
                                                                      searchresponse[
                                                                              0]
                                                                          .description,
                                                                  "brand_id":
                                                                      searchresponse[
                                                                              0]
                                                                          .brandid,
                                                                  "brand_name":
                                                                      searchresponse[
                                                                              0]
                                                                          .brandname,
                                                                  "rate":
                                                                      searchresponse[
                                                                              0]
                                                                          .rate,
                                                                  "quantity":
                                                                      searchresponse[
                                                                              0]
                                                                          .quantity,
                                                                  "warehouse_id":
                                                                      searchresponse[
                                                                              0]
                                                                          .warehouseid,
                                                                  "unit_name":
                                                                      searchresponse[
                                                                              0]
                                                                          .unit_name,
                                                                  "unit_id":
                                                                      searchresponse[
                                                                              0]
                                                                          .unit_id,
                                                                  "arr_units":
                                                                      searchresponse[
                                                                              0]
                                                                          .arr_units,
                                                                  "tax_code":
                                                                      searchresponse[
                                                                              0]
                                                                          .tax_code
                                                                };
                                                                setState(() {
                                                                  itemdetails =
                                                                      data;
                                                                  selectedunit =
                                                                      searchresponse[
                                                                              0]
                                                                          .arr_units[0];
                                                                  array_units =
                                                                      searchresponse[
                                                                              0]
                                                                          .arr_units;
                                                                });
                                                                print(
                                                                    itemdetails);
                                                              }
                                                            }
                                                          },
                                                          elevation: 2.0,
                                                          fillColor:
                                                              Colors.green,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          shape: const CircleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                          child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .barcode,
                                                            color: Colors.white,
                                                            size: 14,
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2),
                                                          child: Text(
                                                            "Scanner",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        RawMaterialButton(
                                                          onPressed: () {
                                                            ClearAllData(model);
                                                          },
                                                          elevation: 2.0,
                                                          fillColor: Colors.red,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          shape: const CircleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                          child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .trash,
                                                            color: Colors.white,
                                                            size: 14,
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2),
                                                          child: Text(
                                                            "Clear All",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        RawMaterialButton(
                                                          onPressed: () async {
                                                            if (customerdetails
                                                                .isEmpty) {
                                                              Get.snackbar(
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      4,
                                                                  "Failed",
                                                                  "Please select customer"
                                                                      .toString(),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  colorText:
                                                                      Colors
                                                                          .white);
                                                            } else {
                                                              if (model.cart
                                                                  .isEmpty) {
                                                                Get.snackbar(
                                                                    maxWidth: MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .width /
                                                                        4,
                                                                    "Failed",
                                                                    "Please select items"
                                                                        .toString(),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    colorText:
                                                                        Colors
                                                                            .white);
                                                              } else {
                                                                print(
                                                                    "This is the total price");
                                                                print(model
                                                                    .total_with_out_vat);

                                                                // Real saving start here
                                                                var received_amount =
                                                                    receivedamountcontroller
                                                                        .text
                                                                        .toString();
                                                                final dynamic
                                                                    calculationresponse =
                                                                    await ApiOrder
                                                                        .convertData(
                                                                            model.cart);
                                                                setState(() {
                                                                  mainloading =
                                                                      true;
                                                                });
                                                                final dynamic saveinvoiceresponse = await ApiOrder.save(
                                                                    userId,
                                                                    customerdetails[
                                                                        "id"],
                                                                    selectedContact
                                                                        .toString(),
                                                                    calculationresponse[
                                                                        "items"],
                                                                    widget
                                                                        .token,
                                                                    footer_discount
                                                                        .toString(),
                                                                    model
                                                                        .footer_discount_Pecentage
                                                                        .toString(),
                                                                    homeDelivery,
                                                                    model
                                                                        .round_off_amount
                                                                        .toString(),
                                                                    model
                                                                        .net_total
                                                                        .toString());
                                                                if (saveinvoiceresponse[
                                                                        "status"] ==
                                                                    "success") {
                                                                  model
                                                                      .removeAll();
                                                                  selectedreceipttype =
                                                                      {};
                                                                  receivedamountcontroller
                                                                      .text = "";
                                                                  authorizationcodecontroller
                                                                      .text = "";
                                                                  barcodeController
                                                                      .text = "";
                                                                  barcodeController
                                                                      .clear();
                                                                  discountController
                                                                      .clear();
                                                                  footer_discount =
                                                                      0;
                                                                  model.footer_discount_Pecentage =
                                                                      0;
                                                                  model.footer_discount_text =
                                                                      "0.00";

                                                                  const PaperSize
                                                                      paper =
                                                                      PaperSize
                                                                          .mm80;
                                                                  final profile =
                                                                      await CapabilityProfile
                                                                          .load();
                                                                  final printer =
                                                                      NetworkPrinter(
                                                                          paper,
                                                                          profile);
                                                                  print(widget
                                                                      .usbdevice);
                                                                  if (widget
                                                                          .usbdevice
                                                                          .isNotEmpty ||
                                                                      true) {
                                                                    var footerDeatils =
                                                                        {
                                                                      "sub_total":
                                                                          saveinvoiceresponse["sub_total"]
                                                                              .toString(),
                                                                      "vat": saveinvoiceresponse[
                                                                          "total_tax_amount"],
                                                                      "total_without_vat":
                                                                          saveinvoiceresponse[
                                                                              "total_wo_vat"],
                                                                      "discount":
                                                                          saveinvoiceresponse["total_discount"]
                                                                              .toString(),
                                                                      "grand_total":
                                                                          saveinvoiceresponse[
                                                                              "grand_total"],
                                                                      "round_off": (saveinvoiceresponse["round_off"] ==
                                                                              null)
                                                                          ? "0"
                                                                          : saveinvoiceresponse[
                                                                              "round_off"],
                                                                      "emirates":
                                                                          saveinvoiceresponse![
                                                                              "emirates"],
                                                                    };
                                                                    for (int i =
                                                                            0;

                                                                        /// sometimes user want 2 copies of invoice;
                                                                        i < widget.numberInvoiceCopy;
                                                                        i++) {
                                                                      OrderListApi.printOrderWindows(
                                                                          BluetoothPrinter(
                                                                              deviceName: widget.usbdevice[
                                                                                  "devicename"],
                                                                              vendorId: widget.usbdevice[
                                                                                  "vendorid"],
                                                                              productId: widget.usbdevice[
                                                                                  "productid"]),
                                                                          printer,
                                                                          saveinvoiceresponse[
                                                                              "items"],
                                                                          imagebytes,
                                                                          saveinvoiceresponse["order_id"]
                                                                              .toString(),
                                                                          saveinvoiceresponse[
                                                                              "customer_name"],
                                                                          saveinvoiceresponse[
                                                                              "order_date"],
                                                                          saveinvoiceresponse[
                                                                              "warehouse_name"],
                                                                          widget.userdetails[
                                                                              "company_name"],
                                                                          widget.userdetails[
                                                                              "billing_address"],
                                                                          widget.userdetails[
                                                                              "genral_phno"],
                                                                          saveinvoiceresponse[
                                                                              "customer_phone"],
                                                                          saveinvoiceresponse[
                                                                              "sales_man"],
                                                                          widget.userdetails[
                                                                              "trn_no"],
                                                                          saveinvoiceresponse[
                                                                              "total_amount"],
                                                                          saveinvoiceresponse[
                                                                              "total_discount"],
                                                                          saveinvoiceresponse[
                                                                              "total_wo_vat"],
                                                                          saveinvoiceresponse["total_tax_amount"]
                                                                              .toString(),
                                                                          saveinvoiceresponse["grand_total"]
                                                                              .toString(),
                                                                          saveinvoiceresponse[
                                                                              "customer_address"],
                                                                          saveinvoiceresponse["order_created_date_time"]
                                                                              .toString(),
                                                                          saveinvoiceresponse["order_id"]
                                                                              .toString(),
                                                                          imgrowdatabytes,
                                                                          footerDeatils);
                                                                    }
                                                                  }
                                                                  // setState(() {
                                                                  //   loading = false;
                                                                  // });
                                                                  // setStateDialog(() {
                                                                  //   dialogueloading = false;
                                                                  // });
                                                                  setState(() {
                                                                    mainloading =
                                                                        false;
                                                                  });
                                                                  model.net_total =
                                                                      0;
                                                                  pushWidgetWhileRemove(
                                                                      newPage: const SuccessPage(
                                                                          screen:
                                                                              dashboard()),
                                                                      context:
                                                                          context);
                                                                } else {
                                                                  setState(() {
                                                                    mainloading =
                                                                        false;
                                                                  });

                                                                  Get.snackbar(
                                                                      maxWidth:
                                                                          MediaQuery.of(context).size.width /
                                                                              4,
                                                                      "Failed",
                                                                      saveinvoiceresponse[
                                                                              "msg"]
                                                                          .toString(),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      colorText:
                                                                          Colors
                                                                              .white);
                                                                }
                                                              }
                                                            }
                                                          },
                                                          elevation: 2.0,
                                                          fillColor:
                                                              Colors.green,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          shape: const CircleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                          child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .check,
                                                            color: Colors.white,
                                                            size: 14,
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2),
                                                          child: Text(
                                                            "Save Order",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                )),
                                Container(
                                  width: 1,
                                  color: API.bordercolor,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          5.5,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            /*
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 2,
                                                                bottom: 4),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Receipt Type"
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            6,
                                                        height: 40,
                                                        child: InputDecorator(
                                                          decoration:
                                                              InputDecoration(
                                                                  filled: true,
                                                                  fillColor:
                                                                      const Color.fromRGBO(
                                                                          248,
                                                                          248,
                                                                          253,
                                                                          1),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: API
                                                                          .bordercolor,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Colors
                                                                          .green,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  hintStyle: const TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      color: Color.fromRGBO(
                                                                          181,
                                                                          184,
                                                                          203,
                                                                          1),
                                                                      fontWeight: FontWeight
                                                                          .w500,
                                                                      fontSize:
                                                                          14),
                                                                  contentPadding:
                                                                      const EdgeInsets.fromLTRB(
                                                                          10.0,
                                                                          10.0,
                                                                          10.0,
                                                                          10.0),
                                                                  // ignore: unnecessary_null_comparison
                                                                  hintText:
                                                                      'Receipt Type',
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(4.0))),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton<
                                                                    dynamic>(
                                                              isExpanded: true,
                                                              dropdownColor:
                                                                  Colors.white,
                                                              hint: const Text(
                                                                'Choose Type',
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            135,
                                                                            141,
                                                                            186,
                                                                            1),
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                              isDense: true,
                                                              value: selectedreceipttype
                                                                      .isEmpty
                                                                  ? null
                                                                  : selectedreceipttype,
                                                              onChanged:
                                                                  (data) async {
                                                                setState(() {
                                                                  selectedreceipttype =
                                                                      data;
                                                                  receivedamountcontroller
                                                                      .text = "";
                                                                });
                                                              },
                                                              items: receipttype
                                                                  .map((value) {
                                                                return DropdownMenuItem<
                                                                        dynamic>(
                                                                    value:
                                                                        value,
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(5.0)),
                                                                      height:
                                                                          20.0,
                                                                      padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                          10.0,
                                                                          2.0,
                                                                          10.0,
                                                                          0.0),
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Text(
                                                                          value['type']
                                                                              .toString()
                                                                              .toUpperCase(),
                                                                          style: TextStyle(
                                                                              fontFamily: 'Montserrat',
                                                                              color: API.textcolor,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    ));
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Discount text box
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 2,
                                                                bottom: 4),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Discount Amount"
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            6,
                                                        height: 40,
                                                        // color: Colors.red,
                                                        child: InputDecorator(
                                                          decoration:
                                                              InputDecoration(
                                                            filled: true,
                                                            fillColor: const Color
                                                                    .fromRGBO(
                                                                248,
                                                                248,
                                                                253,
                                                                1),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: API
                                                                    .bordercolor,
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                              borderSide:
                                                                  const BorderSide(
                                                                color: Colors
                                                                    .green,
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            hintStyle: const TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                color: Color
                                                                    .fromRGBO(
                                                                        181,
                                                                        184,
                                                                        203,
                                                                        1),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    10.0,
                                                                    10.0,
                                                                    10.0,
                                                                    10.0),
                                                            // ignore: unnecessary_null_comparison
                                                            hintText:
                                                                'Discount Amount',
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0)),
                                                          ),
                                                          child: TextField(
                                                            focusNode:
                                                                footerDiscountNode,
                                                            controller:
                                                                discountController,
                                                            decoration: const InputDecoration(
                                                                hintText:
                                                                    "Discount Amount",
                                                                border:
                                                                    InputBorder
                                                                        .none),
                                                            onChanged: (value) {
                                                              if (footerDiscountNode
                                                                  .hasFocus) {
                                                                footer_discount_text =
                                                                    value
                                                                        .toString();
                                                                print("Discount Amount " +
                                                                    footer_discount_text);
                                                                if (footer_discount_text
                                                                    .isEmpty) {
                                                                  footer_discount_text =
                                                                      "0";
                                                                }
                                                                model.LineDiscountEnabled =
                                                                    false;
                                                                model.footer_discount_text =
                                                                    footer_discount_text;
                                                                model
                                                                    .calculateTotalRate();
                                                              }
                                                              setState(() {
                                                                print("");
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        //  Text(((SimpleConvert.safeDouble(cashcard_card == "" ? "0.00" : cashcard_card)) +
                                                        //         (SimpleConvert.safeDouble(cashcard_cash == "" ? "0.00" : cashcard_cash)))
                                                        //     .toStringAsFixed(2)))
                                                      )
                                                    ],
                                                  ),
    
                                                  //
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 2,
                                                                bottom: 4),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Received Amount"
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      selectedreceipttype[
                                                                  "code"] ==
                                                              "CC"
                                                          ? Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6,
                                                              height: 40,
                                                              // color: Colors.red,
                                                              child:
                                                                  InputDecorator(
                                                                      decoration:
                                                                          InputDecoration(
                                                                        filled:
                                                                            true,
                                                                        fillColor: const Color.fromRGBO(
                                                                            248,
                                                                            248,
                                                                            253,
                                                                            1),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                API.bordercolor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          borderSide:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        hintStyle: const TextStyle(
                                                                            fontFamily:
                                                                                'Montserrat',
                                                                            color: Color.fromRGBO(
                                                                                181,
                                                                                184,
                                                                                203,
                                                                                1),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize: 14),
                                                                        contentPadding: const EdgeInsets.fromLTRB(
                                                                            10.0,
                                                                            10.0,
                                                                            10.0,
                                                                            10.0),
                                                                        // ignore: unnecessary_null_comparison
                                                                        hintText:
                                                                            'Received Amount',
                                                                        border: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0)),
                                                                      ),
                                                                      child: Text(receivedamountcontroller
                                                                          .text
                                                                          .toString()))
                                                              //  Text(((SimpleConvert.safeDouble(cashcard_card == "" ? "0.00" : cashcard_card)) +
                                                              //         (SimpleConvert.safeDouble(cashcard_cash == "" ? "0.00" : cashcard_cash)))
                                                              //     .toStringAsFixed(2)))
                                                              )
                                                          : Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6,
                                                              height: 40,
                                                              // color: Colors.red,
                                                              child: TextField(
                                                                readOnly: (selectedreceipttype["code"] ==
                                                                            "" ||
                                                                        selectedreceipttype["code"] ==
                                                                            "CR")
                                                                    ? true
                                                                    : false,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                style: TextStyle(
                                                                    color: API
                                                                        .textcolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration:
                                                                    InputDecoration(
                                                                  filled: true,
                                                                  fillColor:
                                                                      const Color
                                                                              .fromRGBO(
                                                                          248,
                                                                          248,
                                                                          253,
                                                                          1),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: API
                                                                          .bordercolor,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Colors
                                                                          .green,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  hintStyle: const TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      color: Color.fromRGBO(
                                                                          181,
                                                                          184,
                                                                          203,
                                                                          1),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14),
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10.0,
                                                                          10.0,
                                                                          10.0,
                                                                          10.0),
                                                                  // ignore: unnecessary_null_comparison
                                                                  hintText:
                                                                      'Received Amount',
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4.0)),
                                                                ),
                                                                onChanged:
                                                                    (val) {
                                                                  setState(() {
                                                                    receivedamountcontroller
                                                                            .text =
                                                                        val;
                                                                  });
                                                                },
                                                              ),
                                                            )
                                                    ],
                                                  ),
    
                                                  ///
    
                                                  selectedreceipttype["code"] ==
                                                          "CC"
                                                      ? Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 2,
                                                                      bottom:
                                                                          4),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Cash Amount"
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      13,
                                                                  height: 40,
                                                                  // color: Colors.red,
                                                                  child:
                                                                      TextFormField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    style: TextStyle(
                                                                        color: API
                                                                            .textcolor,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      filled:
                                                                          true,
                                                                      fillColor: const Color
                                                                              .fromRGBO(
                                                                          248,
                                                                          248,
                                                                          253,
                                                                          1),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(4.0),
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              API.bordercolor,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(4.0),
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                      ),
                                                                      hintStyle: const TextStyle(
                                                                          fontFamily:
                                                                              'Montserrat',
                                                                          color: Color.fromRGBO(
                                                                              181,
                                                                              184,
                                                                              203,
                                                                              1),
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                              14),
                                                                      contentPadding: const EdgeInsets
                                                                              .fromLTRB(
                                                                          10.0,
                                                                          10.0,
                                                                          10.0,
                                                                          10.0),
                                                                      // ignore: unnecessary_null_comparison
                                                                      hintText:
                                                                          'Cash',
                                                                      border: OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0)),
                                                                    ),
                                                                    onChanged:
                                                                        (val) {
                                                                      setState(
                                                                          () {
                                                                        cash_amount =
                                                                            val;
                                                                      });
                                                                      calculateReceivedAmount();
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 2,
                                                                      bottom:
                                                                          4),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Card Amount"
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontFamily: 'Montserrat'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      13,
                                                                  height: 40,
                                                                  // color: Colors.red,
                                                                  child: TextFormField(
                                                                      keyboardType: TextInputType.number,
                                                                      style: TextStyle(color: API.textcolor, fontWeight: FontWeight.w400),
                                                                      decoration: InputDecoration(
                                                                          filled: true,
                                                                          fillColor: const Color.fromRGBO(248, 248, 253, 1),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: API.bordercolor,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.green,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          hintStyle: const TextStyle(fontFamily: 'Montserrat', color: Color.fromRGBO(181, 184, 203, 1), fontWeight: FontWeight.w500, fontSize: 14),
                                                                          contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                          // ignore: unnecessary_null_comparison
                                                                          hintText: 'Card',
                                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
                                                                      onChanged: (val) {
                                                                        setState(
                                                                            () {
                                                                          card_amount =
                                                                              val;
                                                                        });
                                                                        calculateReceivedAmount();
                                                                      }),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        )
                                                      : const SizedBox(),
                                                  (selectedreceipttype[
                                                                  "code"] ==
                                                              "CA" ||
                                                          selectedreceipttype[
                                                                  "code"] ==
                                                              "CC")
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 2,
                                                                      bottom:
                                                                          4),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Authorization Code"
                                                                        .toUpperCase(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontFamily:
                                                                            'Montserrat'),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  6,
                                                              height: 40,
                                                              // color: Colors.red,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    authorizationcodecontroller,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                style: TextStyle(
                                                                    color: API
                                                                        .textcolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration:
                                                                    InputDecoration(
                                                                        filled:
                                                                            true,
                                                                        fillColor: const Color.fromRGBO(
                                                                            248,
                                                                            248,
                                                                            253,
                                                                            1),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                API.bordercolor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          borderSide:
                                                                              const BorderSide(
                                                                            color:
                                                                                Colors.green,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        hintStyle: const TextStyle(
                                                                            fontFamily:
                                                                                'Montserrat',
                                                                            color: Color.fromRGBO(
                                                                                181,
                                                                                184,
                                                                                203,
                                                                                1),
                                                                            fontWeight: FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                                14),
                                                                        contentPadding: const EdgeInsets.fromLTRB(
                                                                            10.0,
                                                                            10.0,
                                                                            10.0,
                                                                            10.0),
                                                                        // ignore: unnecessary_null_comparison
                                                                        hintText:
                                                                            'Code',
                                                                        border: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0))),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      : SizedBox(),
                                                  const SizedBox(
                                                    height: 1,
                                                  ),
                                                  Divider(
                                                    color: API.bordercolor,
                                                  ),
                                                  const SizedBox(
                                                    height: 1,
                                                  ),
                                                  // Text(
                                                  //   "No of items",
                                                  //   textAlign: TextAlign.start,
                                                  //   style: TextStyle(
                                                  //       color: Colors.black,
                                                  //       fontSize: 12,
                                                  //       fontWeight:
                                                  //           FontWeight.w600,
                                                  //       fontFamily:
                                                  //           'Montserrat'),
                                                  // ),
                                                  // Text(
                                                  //   model.cart.length
                                                  //       .toString(),
                                                  //   textAlign: TextAlign.start,
                                                  //   style: TextStyle(
                                                  //       color: Colors.black,
                                                  //       fontSize: 13,
                                                  //       fontWeight:
                                                  //           FontWeight.w400,
                                                  //       fontFamily:
                                                  //           'Montserrat'),
                                                  // ),
                                                  const SizedBox(height: 3),
                                                  const Text(
                                                    "Sub Total",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    (SimpleConvert.safeDouble(model.subTotal
                                                            .toString()))
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  const Text(
                                                    "Discount",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    (SimpleConvert.safeDouble(model
                                                            .totaldiscount
                                                            .toString()))
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  const Text(
                                                    "Total w/t VAT",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    (SimpleConvert.safeDouble(model
                                                            .total_with_out_vat
                                                            .toString()))
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    "vat".toUpperCase(),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    (SimpleConvert.safeDouble(model.totalvat
                                                            .toString()))
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            */
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Divider(
                                              color: API.bordercolor,
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    7,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10, top: 5),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      const Text(
                                                        " Order Total",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                      const Divider(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            model.net_total
                                                                .toStringAsFixed(
                                                                    2),
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontFamily:
                                                                    'Montserrat'),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      receivedamountcontroller
                                                              .text.isEmpty
                                                          ? const SizedBox()
                                                          : Container(
                                                              // color:
                                                              //     Colors.yellow,
                                                              child: (SimpleConvert.safeDouble(
                                                                          (model.net_total)
                                                                              .toString())) <=
                                                                      0
                                                                  ? const SizedBox()
                                                                  : SimpleConvert.safeDouble(receivedamountcontroller
                                                                              .text) >=
                                                                          (SimpleConvert.safeDouble(
                                                                              (model.net_total).toString()))
                                                                      ? Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width / 5.5,
                                                                          color:
                                                                              Colors.green,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 20, right: 20),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.symmetric(vertical: 5),
                                                                                  child: Text(
                                                                                    "Balance",
                                                                                    textAlign: TextAlign.start,
                                                                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                  child: Text(
                                                                                    (SimpleConvert.safeDouble(receivedamountcontroller.text) - SimpleConvert.safeDouble((SimpleConvert.safeDouble((model.net_total).toString())).toStringAsFixed(2))).toStringAsFixed(2),
                                                                                    textAlign: TextAlign.start,
                                                                                    style: const TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                            ),
                                                    ],
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                  )),
      );
    });
  }

  void LineAddItems(CartModel model) {
    addProducttoTable(model);
    if (model.LineDiscountEnabled) {
      discountController.text =
          model.getTotalofLineDiscount().toStringAsFixed(2);
    }
  }

  void ClearAllData(CartModel model) {
    authorizationcodecontroller.text = "";
    receivedamountcontroller.text = "0";
    discountController.text = "0.00";
    cash_amount = "0";
    card_amount = "";
    selectedreceipttype = receipttype[0];
    model.removeAll();
  }
}
