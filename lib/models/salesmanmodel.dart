class SalesManSchema {
  final String id;
  final String name;

  const SalesManSchema({
    required this.id,
    required this.name,
  });
  static SalesManSchema fromJson(Map<String, dynamic> json) => SalesManSchema(
        id: json['id'].toString(),
        name: json['user_name'],
      );
}
