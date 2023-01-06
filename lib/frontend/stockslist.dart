import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/models/brandmodel.dart';
import 'package:windowspos/models/locationmodel.dart';

class StocksList extends StatefulWidget {
  final String token;
  const StocksList({Key? key, required this.token}) : super(key: key);

  @override
  State<StocksList> createState() => _StocksListState();
}

class _StocksListState extends State<StocksList> {
  bool load = false;
  bool stocktype = true;
  List<dynamic> storelist = [];
  initState() {
    super.initState();
    loadInitSetting();
    setState(() {
      load = true;
    });
    Future.delayed(Duration(seconds: 0), () async {
      String selectedLocationId =
          selectedlocation.isEmpty ? "" : selectedlocation["id"].toString();

      final dynamic storelistresponse = await API.storeListAPI(
          "", "", selectedLocationId, stocktype ? "1" : "2", widget.token);
      print(storelistresponse);
      setState(() {
        storelist = storelistresponse["data"];
        load = false;
      });
    });
  }

  Map<String, dynamic> selectedbrand = {};
  Map<String, dynamic> selectedlocation = {};
  loadInitSetting() async {
    SharedPreferences blueskydehneepos = await SharedPreferences.getInstance();
    String user_id = blueskydehneepos.getString("user_id").toString();
    String user_name = blueskydehneepos.getString("name").toString();

    String warehouse_id = blueskydehneepos.getString("warehouse_id").toString();
    String warehouse_name =
        blueskydehneepos.getString("warehouse_name").toString();
    setState(() {
      selectedlocation = {"id": warehouse_id, "name": warehouse_name};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: API.tilecolor,
        title: Text(
          "Stocks Report",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          Row(
            children: [
              Text(
                "All Items".toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: API.tilewhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
              Switch(
                onChanged: (val) async {
                  setState(() {
                    load = true;
                    stocktype = !stocktype;
                  });
                  final dynamic storelistresponse = await API.storeListAPI(
                      "",
                      selectedbrand.isEmpty ? "" : selectedbrand["id"],
                      selectedlocation.isEmpty ? "" : selectedlocation["id"],
                      stocktype ? "1" : "2",
                      widget.token);
                  print(storelistresponse);
                  if (storelistresponse["status"] == "success") {
                    setState(() {
                      storelist = storelistresponse["data"];
                      load = false;
                    });
                  } else {
                    setState(() {
                      load = false;
                    });
                    Get.snackbar(
                        "Failed", storelistresponse["message"].toString(),
                        backgroundColor: Colors.white,
                        maxWidth: MediaQuery.of(context).size.width / 4,
                        colorText: Colors.red);
                  }
                },
                value: stocktype,
                activeColor: Colors.green,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.redAccent,
                inactiveTrackColor: Colors.redAccent,
              ),
              Text(
                "Having Stock".toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: API.tilewhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
      body: load
          ? Center(
              child: CircularProgressIndicator(
                color: API.tilecolor,
                strokeWidth: 1,
              ),
            )
          : Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  selectedbrand.isNotEmpty
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          height: 48,
                                          decoration: BoxDecoration(
                                              // border:
                                              color: const Color.fromRGBO(
                                                  248, 248, 253, 1),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.green,
                                                  width: 1.0)),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20.0, 15.0, 20.0, 15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      6.2,
                                                  child: Text(
                                                    selectedbrand['name']
                                                        .toString()
                                                        .toString()
                                                        .toUpperCase(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: API.textcolor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 48,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          child: TypeAheadField(
                                              textFieldConfiguration:
                                                  TextFieldConfiguration(
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
                                                    hintText: 'Enter Brand',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0))),
                                              ),
                                              suggestionsCallback:
                                                  (value) async {
                                                if (value == null) {
                                                  return await API
                                                      .getBrandsQueryList(
                                                          value, widget.token);
                                                } else {
                                                  return await API
                                                      .getBrandsQueryList(
                                                          value, widget.token);
                                                }
                                              },
                                              itemBuilder: (context,
                                                  BrandSchema? itemslist) {
                                                final listdata = itemslist;
                                                return ListTile(
                                                  title: Text(
                                                    "${listdata!.name.toUpperCase()}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: API.textcolor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                  ),
                                                );
                                              },
                                              onSuggestionSelected:
                                                  (BrandSchema?
                                                      itemslist) async {
                                                final data = {
                                                  'id': itemslist!.id,
                                                  'name': itemslist.name,
                                                };
                                                setState(() {
                                                  load = true;
                                                  selectedbrand = data;
                                                });
                                                final dynamic
                                                    storelistresponse =
                                                    await API.storeListAPI(
                                                        "",
                                                        selectedbrand.isEmpty
                                                            ? ""
                                                            : selectedbrand[
                                                                "id"],
                                                        selectedlocation.isEmpty
                                                            ? ""
                                                            : selectedlocation[
                                                                "id"],
                                                        stocktype ? "1" : "2",
                                                        widget.token);
                                                print(storelistresponse);
                                                if (storelistresponse[
                                                        "status"] ==
                                                    "success") {
                                                  setState(() {
                                                    storelist =
                                                        storelistresponse[
                                                            "data"];
                                                    load = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    load = false;
                                                  });
                                                  Get.snackbar(
                                                      "Failed",
                                                      storelistresponse[
                                                              "message"]
                                                          .toString(),
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      colorText: Colors.red);
                                                }
                                                print(selectedlocation);
                                              }),
                                        ),
                                  RawMaterialButton(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        load = true;
                                        selectedbrand = {};
                                      });
                                      final dynamic storelistresponse =
                                          await API.storeListAPI(
                                              "",
                                              selectedbrand.isEmpty
                                                  ? ""
                                                  : selectedbrand["id"],
                                              selectedlocation.isEmpty
                                                  ? ""
                                                  : selectedlocation["id"],
                                              stocktype ? "1" : "2",
                                              widget.token);
                                      print(storelistresponse);
                                      if (storelistresponse["status"] ==
                                          "success") {
                                        setState(() {
                                          storelist = storelistresponse["data"];
                                          load = false;
                                        });
                                      } else {
                                        setState(() {
                                          load = false;
                                        });
                                        Get.snackbar(
                                            "Failed",
                                            storelistresponse["message"]
                                                .toString(),
                                            backgroundColor: Colors.white,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            colorText: Colors.red);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  selectedlocation.isNotEmpty
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          height: 48,
                                          decoration: BoxDecoration(
                                              // border:
                                              color: const Color.fromRGBO(
                                                  248, 248, 253, 1),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.green,
                                                  width: 1.0)),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20.0, 15.0, 20.0, 15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      6.2,
                                                  child: Text(
                                                    selectedlocation['name']
                                                        .toString()
                                                        .toString()
                                                        .toUpperCase(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: API.textcolor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 48,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          child: TypeAheadField(
                                              textFieldConfiguration:
                                                  TextFieldConfiguration(
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
                                                    hintText: 'Enter Location',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0))),
                                              ),
                                              suggestionsCallback:
                                                  (value) async {
                                                if (value == null) {
                                                  return await API
                                                      .getLocationsQueryList(
                                                          value, widget.token);
                                                } else {
                                                  return await API
                                                      .getLocationsQueryList(
                                                          value, widget.token);
                                                }
                                              },
                                              itemBuilder: (context,
                                                  LocationSchema? itemslist) {
                                                final listdata = itemslist;
                                                return ListTile(
                                                  title: Text(
                                                    "${listdata!.name.toUpperCase()}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: API.textcolor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                  ),
                                                );
                                              },
                                              onSuggestionSelected:
                                                  (LocationSchema?
                                                      itemslist) async {
                                                final data = {
                                                  'id': itemslist!.id,
                                                  'name': itemslist.name,
                                                };
                                                setState(() {
                                                  load = true;
                                                  selectedlocation = data;
                                                });
                                                final dynamic
                                                    storelistresponse =
                                                    await API.storeListAPI(
                                                        "",
                                                        selectedbrand.isEmpty
                                                            ? ""
                                                            : selectedbrand[
                                                                "id"],
                                                        selectedlocation.isEmpty
                                                            ? ""
                                                            : selectedlocation[
                                                                "id"],
                                                        stocktype ? "1" : "2",
                                                        widget.token);
                                                print(storelistresponse);
                                                if (storelistresponse[
                                                        "status"] ==
                                                    "success") {
                                                  setState(() {
                                                    storelist =
                                                        storelistresponse[
                                                            "data"];
                                                    load = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    load = false;
                                                  });
                                                  Get.snackbar(
                                                      "Failed",
                                                      storelistresponse[
                                                              "message"]
                                                          .toString(),
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      colorText: Colors.red);
                                                }
                                                print(selectedlocation);
                                              }),
                                        ),
                                  RawMaterialButton(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        load = true;
                                        selectedlocation = {};
                                      });
                                      final dynamic storelistresponse =
                                          await API.storeListAPI(
                                              "",
                                              selectedbrand.isEmpty
                                                  ? ""
                                                  : selectedbrand["id"],
                                              selectedlocation.isEmpty
                                                  ? ""
                                                  : selectedlocation["id"],
                                              stocktype ? "1" : "2",
                                              widget.token);
                                      print(storelistresponse);
                                      if (storelistresponse["status"] ==
                                          "success") {
                                        setState(() {
                                          storelist = storelistresponse["data"];
                                          load = false;
                                        });
                                      } else {
                                        setState(() {
                                          load = false;
                                        });
                                        Get.snackbar(
                                            "Failed",
                                            storelistresponse["message"]
                                                .toString(),
                                            backgroundColor: Colors.white,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            colorText: Colors.red);
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Card(
                              elevation: 40,
                              semanticContainer: true,
                              child: Container(
                                color: Colors.white,
                                child: TextFormField(
                                  cursorColor: Colors.green,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green.withOpacity(0.8),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: API.bordercolor,
                                          width: 1.0,
                                        ),
                                      ),
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400),
                                      labelText: 'Search Now',
                                      border: OutlineInputBorder()),
                                  onChanged: (value) async {
                                    final dynamic storelistresponse =
                                        await API.storeListAPI(
                                            value.isEmpty ? "" : value,
                                            selectedbrand.isEmpty
                                                ? ""
                                                : selectedbrand["id"],
                                            selectedlocation.isEmpty
                                                ? ""
                                                : selectedlocation["id"],
                                            stocktype ? "1" : "2",
                                            widget.token);
                                    print(storelistresponse);
                                    if (storelistresponse["status"] ==
                                        "success") {
                                      setState(() {
                                        storelist = storelistresponse["data"];
                                      });
                                    } else {
                                      setState(() {});
                                      Get.snackbar(
                                          "Failed",
                                          storelistresponse["message"]
                                              .toString(),
                                          backgroundColor: Colors.white,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          colorText: Colors.red);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Expanded(
                        child: Container(
                      child: storelist.length == 0
                          ? SizedBox(
                              child: Center(
                                child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                    width: MediaQuery.of(context).size.width,
                                    child:
                                        Image.asset("assets/images/box.png")),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    horizontalMargin: 12,
                                    columnSpacing: MediaQuery.of(context)
                                                .size
                                                .width >
                                            1600
                                        ? MediaQuery.of(context).size.width / 8
                                        : MediaQuery.of(context).size.width >
                                                    1200 &&
                                                MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1600
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10
                                            : MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600 &&
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        1200
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    15
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    20,
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                            'Part No',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 13
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1200 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1600
                                                        ? 12
                                                        : MediaQuery.of(context)
                                                                        .size
                                                                        .width >
                                                                    600 &&
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    1200
                                                            ? 11
                                                            : 10,
                                                fontWeight: FontWeight.w800,
                                                color: API.textcolor),
                                          ),
                                          tooltip: 'Part Number'),
                                      DataColumn(
                                          label: Text(
                                            'Description',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 13
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1200 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1600
                                                        ? 12
                                                        : MediaQuery.of(context)
                                                                        .size
                                                                        .width >
                                                                    600 &&
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    1200
                                                            ? 11
                                                            : 10,
                                                fontWeight: FontWeight.w800,
                                                color: API.textcolor),
                                          ),
                                          tooltip: 'Description'),
                                      DataColumn(
                                          label: Text(
                                            'Brand Name',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 13
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1200 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1600
                                                        ? 12
                                                        : MediaQuery.of(context)
                                                                        .size
                                                                        .width >
                                                                    600 &&
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    1200
                                                            ? 11
                                                            : 10,
                                                fontWeight: FontWeight.w800,
                                                color: API.textcolor),
                                          ),
                                          tooltip: 'Brand Name'),
                                      DataColumn(
                                          label: Text(
                                            'Generic Name',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 13
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1200 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1600
                                                        ? 12
                                                        : MediaQuery.of(context)
                                                                        .size
                                                                        .width >
                                                                    600 &&
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    1200
                                                            ? 11
                                                            : 10,
                                                fontWeight: FontWeight.w800,
                                                color: API.textcolor),
                                          ),
                                          tooltip: 'Generic Name'),
                                      DataColumn(
                                          label: Text(
                                            'Qty',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 13
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1200 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1600
                                                        ? 12
                                                        : MediaQuery.of(context)
                                                                        .size
                                                                        .width >
                                                                    600 &&
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    1200
                                                            ? 11
                                                            : 10,
                                                fontWeight: FontWeight.w800,
                                                color: API.textcolor),
                                          ),
                                          tooltip: 'Quantity'),
                                      // DataColumn(
                                      //     label: Text(
                                      //       'Cost',
                                      //       style: TextStyle(
                                      //           fontFamily: 'Montserrat',
                                      //           fontSize: 13,
                                      //           fontWeight: FontWeight.w800,
                                      //           color: API.textcolor),
                                      //     ),
                                      //     tooltip: 'Process start date'),
                                      DataColumn(
                                          label: Text(
                                            'Sales Price',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 13
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1200 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1600
                                                        ? 12
                                                        : MediaQuery.of(context)
                                                                        .size
                                                                        .width >
                                                                    600 &&
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    1200
                                                            ? 11
                                                            : 10,
                                                fontWeight: FontWeight.w800,
                                                color: API.textcolor),
                                          ),
                                          tooltip: 'Sales price'),
                                      // DataColumn(
                                      //     label: Text(
                                      //       'Gross Total',
                                      //       style: TextStyle(
                                      //           fontFamily: 'Montserrat',
                                      //           fontSize: 13,
                                      //           fontWeight: FontWeight.w800,
                                      //           color: API.textcolor),
                                      //     ),
                                      //     tooltip: 'Number Of Days'),
                                    ],
                                    rows: storelist
                                        .map<DataRow>((e) => DataRow(cells: [
                                              DataCell(
                                                Text(
                                                  e['part_number']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              1600
                                                          ? 13
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      1200 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1600
                                                              ? 12
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 11
                                                                  : 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: API.textcolor),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e["description"].toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              1600
                                                          ? 13
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      1200 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1600
                                                              ? 12
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 11
                                                                  : 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: API.textcolor),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e["brand_name"].toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              1600
                                                          ? 13
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      1200 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1600
                                                              ? 12
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 11
                                                                  : 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: API.textcolor),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e["generic_name"].toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              1600
                                                          ? 13
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      1200 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1600
                                                              ? 12
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 11
                                                                  : 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: API.textcolor),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  double.parse(
                                                          e["available_qty"]
                                                              .toString())
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              1600
                                                          ? 13
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      1200 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1600
                                                              ? 12
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 11
                                                                  : 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: API.textcolor),
                                                ),
                                              ),
                                              // DataCell(
                                              //   Text(
                                              //     double.parse(e["rate"]
                                              //             .toString())
                                              //         .toStringAsFixed(2),
                                              //     style: TextStyle(
                                              //         fontFamily:
                                              //             'Montserrat',
                                              //         fontSize: 12,
                                              //         fontWeight:
                                              //             FontWeight.w800,
                                              //         color: API.textcolor),
                                              //   ),
                                              // ),
                                              DataCell(
                                                Text(
                                                  double.parse(
                                                          e["selling_price"]
                                                              .toString())
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              1600
                                                          ? 13
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      1200 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1600
                                                              ? 12
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 11
                                                                  : 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: API.textcolor),
                                                ),
                                              ),
                                              // DataCell(
                                              //   Text(
                                              //     double.parse(
                                              //             e["gross_total"]
                                              //                 .toString())
                                              //         .toStringAsFixed(2),
                                              //     style: TextStyle(
                                              //         fontFamily:
                                              //             'Montserrat',
                                              //         fontSize: 12,
                                              //         fontWeight:
                                              //             FontWeight.w800,
                                              //         color: API.textcolor),
                                              //   ),
                                              // ),
                                            ]))
                                        .toList(),
                                  )),
                            ),
                    ))
                  ],
                ),
              ),
            ),
    );
  }
}
