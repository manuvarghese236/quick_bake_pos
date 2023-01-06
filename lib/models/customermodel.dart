class CustomerSchema {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String location;
  List arr_contacts = [];
  CustomerSchema(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.location,
      required this.arr_contacts});
  static CustomerSchema fromJson(Map<String, dynamic> json) => CustomerSchema(
      id: json['id'],
      name: json['name'],
      phone: json["phone"],
      email: json["email"],
      location: json["location"],
      arr_contacts: json['arr_contacts']);
}
