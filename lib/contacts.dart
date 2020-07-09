class Contact {
  int contactnumber;
  String name;
  String address;
  int id;
  String email;

  Contact({this.contactnumber, this.address, this.id, this.name, this.email});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'contactnumber': contactnumber,
      'email': email
    };
    return map;
  }

  Contact.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    address = map['address'];
    contactnumber = map['contactnumber'];
    email = map['email'];
  }
}
