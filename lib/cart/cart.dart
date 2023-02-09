// ignore_for_file: non_constant_identifier_names

import 'package:scoped_model/scoped_model.dart';
import 'package:windowspos/models/itemmodel.dart';

class SimpleConvert {
  static double safeDouble(String? number) {
    if (number == null) {
      return 0.0;
    } else {
      String sanitizeNum = number.replaceAll(",", "");
      double? doubleNum = double.tryParse(sanitizeNum);
      return (doubleNum == null) ? 0.0 : doubleNum;
    }
  }
}

class CartModel extends Model {
  List<ItemSchema> cart = [];
  bool LineDiscountEnabled = false;
  double total_with_out_vat = 0;
  double subTotal = 0;
  double totaldiscount = 0;
  double totalvat = 0;
  double footer_discount = 0;
  double footer_discount_Pecentage = 0.00;
  String footer_discount_text = "";
  double net_total = 0;

  int get total => cart.length;
  double getTotalofLineDiscount() {
    double totalDiscount = 0;
    cart.forEach((element) {
      totalDiscount += element.discount;
    });
    return totalDiscount;
  }

  void calculateDiscountFromLineTotal() {
    double totalDiscount = 0;
    double _total_amount = 0;
    footer_discount = 0;
    cart.forEach((element) {
      //sum of discount
      footer_discount += element.discount;
      double discount_amt = element.discount;
      element.discountvalue = discount_amt;
      //line total
      double eachtotal = SimpleConvert.safeDouble(element.rate) *
          SimpleConvert.safeDouble(element.quantity);
      // running line total
      _total_amount += eachtotal;
      element.totalAmount = eachtotal;
      double tax_code = double.parse(element.tax_code) / 100;
      double afterDiscountedAmount = eachtotal - discount_amt;

      double vat_amount = (afterDiscountedAmount * tax_code) / (1 + tax_code);
      element.vatafterdiscount = vat_amount;

      element.subtotalafterdiscount = (afterDiscountedAmount - vat_amount);
      element.totalafterdiscount = afterDiscountedAmount;
      //discount percentage
      element.discount_percentage = (element.discount * 100) / eachtotal;
      element.discountpercentagevalue = element.discount_percentage;
    });
    footer_discount_Pecentage = (footer_discount * 100) / _total_amount;
  }

  void calculateDiscountFromFooterDiscount() {
    bool isPercentage = false;
    double? _percentage = 0.0;

    double itemTotal = 0;
    cart.forEach((element) {
      double rate = double.parse(element.rate);

      itemTotal += double.parse(element.quantity) * rate;
    });
    if (footer_discount_text.contains("%")) {
      isPercentage = true;
      _percentage = double.parse(footer_discount_text.replaceAll("%", ""));
      if (_percentage != null) {
        footer_discount = itemTotal * _percentage / 100;
      }
    } else {
      double? _val = double.tryParse(footer_discount_text);
      if (_val != null) {
        footer_discount = _val;
      }
    }
    cart.forEach((element) {
      double rate = double.parse(element.rate);
      double eachtotal = double.parse(element.quantity) * rate;
      element.totalAmount = eachtotal;

      double discount_amt = (eachtotal / itemTotal) * footer_discount;
      element.discountvalue = discount_amt;
      double tax_code = double.parse(element.tax_code) / 100;
      double afterDiscountedAmount = eachtotal - discount_amt;

      double vat_amount = (afterDiscountedAmount * tax_code) / (1 + tax_code);
      element.vatafterdiscount = vat_amount;

      element.subtotalafterdiscount = (afterDiscountedAmount - vat_amount);
      element.totalafterdiscount = afterDiscountedAmount;

      double discount_percentage = (discount_amt * 100) / eachtotal;
      element.discount_percentage = discount_percentage;
      element.discountpercentagevalue = discount_percentage;
    });
    double _total_amount = getMaxDiscount();
    footer_discount_Pecentage = (footer_discount * 100) / _total_amount;
  }

  double getMaxDiscount() {
    double itemTotal = 0;
    cart.forEach((element) {
      double rate = double.parse(element.rate);

      itemTotal += double.parse(element.quantity) * rate;
    });
    return itemTotal;
  }

  void calculateTotalRate() {
    if (LineDiscountEnabled) {
      calculateDiscountFromLineTotal();
    } else {
      calculateDiscountFromFooterDiscount();
    }
    total_with_out_vat = 0;
    totalvat = 0;
    subTotal = 0;
    totaldiscount = 0;
    net_total = 0;
    footer_discount = 0;
    cart.forEach((cal) {
      totaldiscount += double.parse(cal.discountvalue.toString());

      double rate = double.parse(cal.rate);
      double eachtotal = double.parse(cal.quantity) * rate;

      net_total += eachtotal;

      total_with_out_vat += double.parse(cal.subtotalafterdiscount.toString());

      subTotal += eachtotal;
      totalvat += cal.vatafterdiscount;
      footer_discount += cal.discountvalue;
    });
    net_total = subTotal - footer_discount;
    notifyListeners();
  }

  void addProduct(product) {
    cart.add(product);
    notifyListeners();
  }

  void removeProduct(String productid) {
    cart.removeWhere((val) => val.id == productid);
    notifyListeners();
  }

  void removeAll() {
    cart.clear();
    total_with_out_vat = 0;
    totalvat = 0;
    totaldiscount = 0;
    footer_discount = 0;
    footer_discount_Pecentage = 0;
    footer_discount_text = "";
    subTotal = 0;
    calculateTotalRate();
    notifyListeners();
  }

  bool checkItems(String productid, List<ItemSchema> cartlist) {
    for (var e in cartlist) {
      print(e.id);
      if (e.id == productid) {
        print("The element in the cart is");
        print(e.quantity);
        return true;
      }
    }

    return false;
  }

  bool hasQtyInStock(String productid, List<ItemSchema> cartlist, String Qty,
      String totalQty) {
    double _qtyDouble = SimpleConvert.safeDouble(Qty);
    double _totalQty = SimpleConvert.safeDouble(totalQty);
    double _currenCartQty = 0;
    bool status = true;
    for (var e in cartlist) {
      print(e.id);
      if (e.id == productid) {
        _currenCartQty = SimpleConvert.safeDouble(e.quantity);
      }
    }
    return (_qtyDouble <= (_totalQty - _currenCartQty));
  }
}
