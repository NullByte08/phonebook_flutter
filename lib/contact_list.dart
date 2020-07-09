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
  String name;
  int curUserId;
  int contactNumber;
  String address;

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
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Contact c = Contact(
            contactnumber: contactNumber,
            id: curUserId,
            address: address,
            name: name);
        dbHelper.update(c);
        setState(() {
          isUpdating = false;
        });
      } else {
        Contact c = Contact(
            id: null,
            contactnumber: contactNumber,
            address: address,
            name: name);
        dbHelper.save(c);
        clearName();
      }
      refreshList();
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
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Phone Number'),
              validator: (val) => val.length == 0 ? 'Enter Number' : null,
              onSaved: (val) => contactNumber = int.parse(val),
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
