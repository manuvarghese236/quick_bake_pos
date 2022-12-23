class LocationSchema {
  final String id;
  final String name;

  const LocationSchema({
    required this.id,
    required this.name,
  });
  static LocationSchema fromJson(Map<String, dynamic> json) => LocationSchema(
        id: json['id'],
        name: json['warehouse_name'],
      );
}
