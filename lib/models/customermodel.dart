class CustomerSchema {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String location;

  const CustomerSchema(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.location});
  static CustomerSchema fromJson(Map<String, dynamic> json) => CustomerSchema(
      id: json['id'],
      name: json['name'],
      phone: json["phone"],
      email: json["email"],
      location: json["location"]);
}
