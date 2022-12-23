class ItemSchema {
  final String id;
  final String partnumber;
  final String description;
  final String brandid;
  final String brandname;
  final String rate;
  String quantity;
  final String warehouseid;
  final String unit_name;
  final String unit_id;
  final List<dynamic> arr_units;
  final String tax_code;
  String discount;
  final String availableqty;
  String discount_percentage;
  String discountvalue;
  String discountpercentagevalue;

  ///This is the net paybale of the line item after discount;
  String totalafterdiscount;
  String vatafterdiscount;
  String subtotalafterdiscount;

  final String barcode;

  ///rate * qty  => total_amount
  String totalAmount = "";

  ItemSchema(
      {required this.id,
      required this.partnumber,
      required this.description,
      required this.brandid,
      required this.brandname,
      required this.rate,
      required this.quantity,
      required this.warehouseid,
      required this.unit_name,
      required this.unit_id,
      required this.arr_units,
      required this.tax_code,
      required this.discount,
      required this.availableqty,
      required this.discount_percentage,
      required this.discountvalue,
      required this.discountpercentagevalue,
      required this.totalafterdiscount,
      required this.vatafterdiscount,
      required this.subtotalafterdiscount,
      required this.barcode});

  static ItemSchema fromJson(Map<String, dynamic> json) => ItemSchema(
      id: json['id'],
      partnumber: json['part_number'],
      description: json['description'],
      brandid: json["brand_id"],
      brandname: json["brand_name"],
      rate: json["selling_price"],
      quantity: json["quantity"].toString(),
      warehouseid: json["warehouse_id"].toString(),
      unit_name: json["unit_name"].toString(),
      unit_id: json["unit_id"].toString(),
      arr_units: json["arr_units"],
      tax_code: json["tax_code"],
      discount: json["discount"].toString(),
      availableqty: json["available_qty"].toString(),
      discount_percentage: json["discount_percentage"].toString(),
      discountvalue: json["discountvalue"].toString(),
      discountpercentagevalue: json["discountpercentagevalue"].toString(),
      totalafterdiscount: json["totalafterdiscount"].toString(),
      vatafterdiscount: json["vatafterdiscount"].toString(),
      subtotalafterdiscount: json["subtotalafterdiscount"].toString(),
      barcode: json["bar_code"].toString());
}
