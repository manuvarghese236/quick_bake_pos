class BrandSchema {
  final String id;
  final String name;

  const BrandSchema({
    required this.id,
    required this.name,
  });
  static BrandSchema fromJson(Map<String, dynamic> json) => BrandSchema(
        id: json['id'].toString(),
        name: json['name'].toString(),
      );
}
