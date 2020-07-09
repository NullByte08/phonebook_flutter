import 'package:flutter/material.dart';
import 'package:phonebook/db_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'contacts.dart';

class ContactDetails extends StatefulWidget {
  ContactDetails({this.curUserId, this.name, this.number});

  final int curUserId;
  final String name;
  final int number;

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  int curUserid;
  Database db;
  var dbHelper;
  String name;
  String address;
  int contactNumber;
  bool isUpdating = true;
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    curUserid = widget.curUserId;
    controller.text = widget.name;
    controller2.text = widget.number.toString();
    dbHelper = DBHelper();
    db = DBHelper().getDatabase();
  }

  clearName() {
    controller.text = '';
    controller2.text = '';
    controller3.text = '';
  }

  Future<List<Map>> getContactDetails(int uid) async {
    return await db.rawQuery('SELECT * FROM my_table WHERE id=?', [curUserid]);
  }

  contact(List<Map> listOfMaps) {
    name = listOfMaps[0]['name'] as String;
    contactNumber = listOfMaps[0]['contactnumber'] as int;
    address = listOfMaps[0]['address'] as String;
    controller.text = name;
    controller2.text = contactNumber.toString();
    controller3.text = address;
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: getContactDetails(curUserid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return contact(snapshot.data);
          }
          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  final formKey = new GlobalKey<FormState>();

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Contact c = Contact(
            contactnumber: contactNumber,
            id: curUserid,
            address: address,
            name: name);
        dbHelper.update(c);
        /*setState(() {
          //isUpdating = false;
        });*/
      } else {
        Contact c = Contact(
            id: null,
            contactnumber: contactNumber,
            address: address,
            name: name);
        dbHelper.save(c);
        clearName();
      }
      Navigator.pop(context, "pop");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PhoneBook',
        ),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (val) => val.length == 0 ? 'Enter Name' : null,
                  onSaved: (val) => name = val,
                ),
                TextFormField(
                  controller: controller2,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (val) => val.length == 0 ? 'Enter Number' : null,
                  onSaved: (val) => contactNumber = int.parse(val),
                ),
                TextFormField(
                  controller: controller3,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (val) => val.length == 0 ? 'Enter Address' : null,
                  onSaved: (val) => address = val,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      onPressed: validate,
                      child: Text(
                        isUpdating ? 'UPDATE' : 'ADD',
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context, "pop");
                        clearName();
                      },
                      child: Text('CANCEL'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
