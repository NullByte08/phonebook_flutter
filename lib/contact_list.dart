import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonebook/contact_details.dart';
import 'package:phonebook/db_helper.dart';
import 'package:phonebook/groups.dart';

import 'contacts.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  Future<List<Contact>> contacts;
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  String name;
  int curUserId;
  int contactNumber;
  String address;
  String email;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      contacts = dbHelper.getContacts();
    });
  }

  clearName() {
    controller.text = '';
    controller2.text = '';
    controller3.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Contact c = Contact(
            contactnumber: contactNumber,
            id: curUserId,
            address: address,
            name: name,
            email: email);
        dbHelper.update(c);
        setState(() {
          isUpdating = false;
        });
      } else {
        Contact c = Contact(
            id: null,
            contactnumber: contactNumber,
            address: address,
            name: name,
            email: email);
        dbHelper.save(c);
        clearName();
      }
      refreshList();
    }
  }

  String validatePhoneNumber(String value) {
    if (value.length != 10)
      return 'Invalid Number';
    else
      return null;
  }

  String validateEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (emailValid) {
      return null;
    } else {
      return 'Invalid Email';
    }
  }

  form() {
    return Form(
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
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number'),
              validator: validatePhoneNumber,
              onSaved: (val) => contactNumber = int.parse(val),
            ),
            TextFormField(
              controller: controller3,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              validator: validateEmail,
              onSaved: (val) => email = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate,
                  child: Text(
                      //isUpdating ? 'UPDATE' : 'ADD',
                      "ADD"),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                    });
                    clearName();
                  },
                  child: Text('CANCEL'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Contact> contacts) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(label: Text('NAME')),
          DataColumn(label: Text('PHONE')),
          DataColumn(label: Text('EMAIL')),
          DataColumn(
            label: Text('DELETE'),
          )
        ],
        rows: contacts
            .map(
              (contact) => DataRow(
                cells: [
                  DataCell(
                    Text(contact.name),
                    onTap: () {
                      setState(() {
                        //isUpdating = true;
                        curUserId = contact.id;
                      });
                      /*controller.text = contact.name;
                      controller2.text = contact.contactnumber.toString();*/
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactDetails(
                                    curUserId: curUserId,
                                    name: contact.name,
                                    number: contact.contactnumber,
                                  ))).then((value) {
                        setState(() {
                          refreshList();
                        });
                      });
                    },
                  ),
                  DataCell(
                    Text(contact.contactnumber.toString()),
                    onTap: () {
                      setState(() {
                        //isUpdating = true;
                        curUserId = contact.id;
                      });
                      /*controller.text = contact.name;
                      controller2.text = contact.contactnumber.toString();*/
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactDetails(
                                    curUserId: curUserId,
                                    name: contact.name,
                                    number: contact.contactnumber,
                                  ))).then((value) {
                        setState(() {
                          refreshList();
                        });
                      });
                    },
                  ),
                  DataCell(
                    Text(contact.email),
                    onTap: () {
                      setState(() {
                        //isUpdating = true;
                        curUserId = contact.id;
                      });
                      /*controller.text = contact.name;
                      controller2.text = contact.contactnumber.toString();*/
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactDetails(
                                    curUserId: curUserId,
                                    name: contact.name,
                                    number: contact.contactnumber,
                                  ))).then((value) {
                        setState(() {
                          refreshList();
                        });
                      });
                    },
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(contact.id);
                        refreshList();
                      },
                    ),
                  )
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: contacts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }
          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Create Groups':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => GroupScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text("PhoneBook"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Create Groups'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: [
                form(),
                list(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
