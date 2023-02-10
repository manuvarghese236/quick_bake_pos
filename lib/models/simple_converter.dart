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
