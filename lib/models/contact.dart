class CustomerContact {
  final String id;
  final String person_name;
  final String contact_mobile_no;
  final String latitude;
  final String longitude;
  CustomerContact(
      {required this.id,
      required this.person_name,
      required this.contact_mobile_no,
      required this.latitude,
      required this.longitude});
  getJson() {
    return {
      "id": id,
      "person_name": person_name,
      "contact_mobile_no": contact_mobile_no,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
