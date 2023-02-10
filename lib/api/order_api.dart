import 'dart:convert';

import 'package:http/http.dart';
import 'package:windowspos/api/api.dart';

import '../models/itemmodel.dart';

class ApiOrder {
  static Future<Map<String, dynamic>> save(
    String userid,
    String customerid,
    String contactId,
    List<dynamic> items,
    String token,
    String footer_discount,
    String footer_discount_Pecentage,
    bool homeDelivery,
    String round_off,
    String grand_total,
  ) async {
    String baseurl = API.baseurl;
    final saveinvoiceurl = "${baseurl}apiorder/saveorder";
    try {
      var data = json.encode(
        {
          "created_by": userid,
          "customer_id": customerid,
          "contact_id": contactId,
          "items": items,
          "footer_discount": footer_discount,
          "footer_discount_percentage": footer_discount_Pecentage,
          "round_off": round_off,
          "grand_total": grand_total
        },
      );
      print(saveinvoiceurl);
      print(token);
      print(data);
      print("------------------");
      final response = await post(
        Uri.parse(saveinvoiceurl),
        headers: {"Accept": "application/json", "token": token},
        body: data,
      );

      if (response.statusCode == 200) {
        dynamic saveinvoiceresponse = jsonDecode(response.body);
        print(saveinvoiceresponse);
        return saveinvoiceresponse;
      } else {
        print(response.body);
        print("saveInvoiceAPI failed " + response.reasonPhrase.toString());
        return {'status': 'failed', 'msg': response.reasonPhrase.toString()};
      }
    } catch (err) {
      return {"status": "failed", "msg": err.toString()};
    }
  }

  static Future<Map<String, dynamic>> convertData(List<ItemSchema> data) async {
    num totalamount = 0.00;
    num totalvat = 0.00;
    List<dynamic> itemdetails = [];
    for (int i = 0; i < data.length; i++) {
      final eachresult = {
        "product_id": data[i].id,
        "description": data[i].description,
        "rate": data[i].rate,
        "quantity": data[i].quantity,
        "warehouse_id": data[i].warehouseid,
        "total_amount": data[i].totalAmount,
        "unit_id": data[i].unit_id,
        "tax_code": data[i].tax_code,
        "discount_amount": data[i].discountvalue,
        "discount_percentage": data[i].discount_percentage,
        "grand_total": data[i].totalafterdiscount,
        "tax_vat_amount": double.parse(data[i].vatafterdiscount.toString()),
        "net_per_item": double.parse(data[i].totalafterdiscount.toString()) /
            double.parse(data[i].quantity.toString()),
      };
      print("This is the data inside order cart send to backend");
      print(eachresult);
      itemdetails.add(eachresult);
    }
    return {"items": itemdetails};
    // return {"total": totalamount, "items": itemdetails, "vat": totalvat};
  }
}
