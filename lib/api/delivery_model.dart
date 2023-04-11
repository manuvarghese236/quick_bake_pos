import 'dart:convert';

import 'package:http/http.dart';

import 'api.dart';

class DeliveryCharge {
  String? id;
  String? partNumber;
  String? description;
  String? brandId;
  String? brandName;
  String? rate;
  String? quantity;
  String? warehouseId;
  String? unitName;
  String? unitId;
  List<ArrUnits>? arrUnits;
  String? taxCode;
  int? discount;
  String? availableQty;
  int? discountPercentage;
  int? discountvalue;
  int? discountpercentagevalue;
  int? totalafterdiscount;
  int? vatafterdiscount;
  int? subtotalafterdiscount;
  String? barCode;
  int? inventoryItemType;

  DeliveryCharge(
      {this.id,
      this.partNumber,
      this.description,
      this.brandId,
      this.brandName,
      this.rate,
      this.quantity,
      this.warehouseId,
      this.unitName,
      this.unitId,
      this.arrUnits,
      this.taxCode,
      this.discount,
      this.availableQty,
      this.discountPercentage,
      this.discountvalue,
      this.discountpercentagevalue,
      this.totalafterdiscount,
      this.vatafterdiscount,
      this.subtotalafterdiscount,
      this.barCode,
      this.inventoryItemType});

  DeliveryCharge.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    partNumber = json['part_number'];
    description = json['description'];
    brandId = json['brand_id'];
    brandName = json['brand_name'];
    rate = json['rate'];
    quantity = json['quantity'];
    warehouseId = json['warehouse_id'];
    unitName = json['unit_name'];
    unitId = json['unit_id'];
    if (json['arr_units'] != null) {
      arrUnits = <ArrUnits>[];
      json['arr_units'].forEach((v) {
        arrUnits!.add(ArrUnits.fromJson(v));
      });
    }
    taxCode = json['tax_code'];
    discount = json['discount'];
    availableQty = json['available_qty'];
    discountPercentage = json['discount_percentage'];
    discountvalue = json['discountvalue'];
    discountpercentagevalue = json['discountpercentagevalue'];
    totalafterdiscount = json['totalafterdiscount'];
    vatafterdiscount = json['vatafterdiscount'];
    subtotalafterdiscount = json['subtotalafterdiscount'];
    barCode = json['bar_code'];
    inventoryItemType = json['inventory_item_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['part_number'] = partNumber;
    data['description'] = description;
    data['brand_id'] = brandId;
    data['brand_name'] = brandName;
    data['rate'] = rate;
    data['quantity'] = quantity;
    data['warehouse_id'] = warehouseId;
    data['unit_name'] = unitName;
    data['unit_id'] = unitId;
    if (arrUnits != null) {
      data['arr_units'] = arrUnits!.map((v) => v.toJson()).toList();
    }
    data['tax_code'] = taxCode;
    data['discount'] = discount;
    data['available_qty'] = availableQty;
    data['discount_percentage'] = discountPercentage;
    data['discountvalue'] = discountvalue;
    data['discountpercentagevalue'] = discountpercentagevalue;
    data['totalafterdiscount'] = totalafterdiscount;
    data['vatafterdiscount'] = vatafterdiscount;
    data['subtotalafterdiscount'] = subtotalafterdiscount;
    data['bar_code'] = barCode;
    data['inventory_item_type'] = inventoryItemType;
    return data;
  }
}

class ArrUnits {
  int? id;
  String? unitName;
  int? unitFactor;
  int? unitPrice;

  ArrUnits({this.id, this.unitName, this.unitFactor, this.unitPrice});

  ArrUnits.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unitName = json['unit_name'];
    unitFactor = json['unit_factor'];
    unitPrice = json['unit_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['unit_name'] = unitName;
    data['unit_factor'] = unitFactor;
    data['unit_price'] = unitPrice;
    return data;
  }
}

getDeliveryCharges(token) async {
  final url = '${API.baseurl}Apistore/DeliveryCharges';
  print(token);
  print(url);
  print(url);
  final response = await get(
    Uri.parse(url),
    headers: {"Accept": "application/json", 'token': token},
  );
  print(response.body);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return {"status": "error", "message": response.reasonPhrase};
  }
}
