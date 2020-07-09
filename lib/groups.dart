import 'package:flutter/material.dart';
import 'package:phonebook/contacts.dart';
import 'package:phonebook/db_helper.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Future<List<Contact>> contacts;
  var dbHelper;
  TextEditingController controller = TextEditingController();
  String name;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    refreshList();
  }

  refreshList() {
    setState(() {
      contacts = dbHelper.getContacts();
    });
  }

  List<bool> selectedList = [];

  SingleChildScrollView dataTable(List<Contact> contacts) {
    List<Widget> names = [];
    for (int i = 0; i < contacts.length; i++) {
      selectedList.add(false);
      names.add(
        CheckboxListTile(
          title: Text(contacts[i].name),
          value: selectedList[i],
          onChanged: (bool value) {
            setState(() {
              selectedList[i] = selectedList[i] ? false : true;
            });
          },
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      /*child: DataTable(
        columns: [
          DataColumn(label: Text('NAME')),
          DataColumn(label: Text('PHONE')),
          DataColumn(
            label: Text('DELETE'),
          )
        ],
        rows: contacts
            .map(
              (contact) => Row(),
        )
            .toList(),
      ),*/
      child: Column(
        children: names,
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

  List<Widget> groups = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text(
          "Create Group",
        ),
      ),
      body: Column(
        children: [
          list(),
          Text("Group List"),
          Column(
            children: groups,
          ),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: 'Group Name'),
            validator: (val) => val.length == 0 ? 'Enter Group Name' : null,
            onSaved: (val) => name = val,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    groups.add(Text(name));
                    controller.text = '';
                  });
                },
                child: Text(
                    //isUpdating ? 'UPDATE' : 'ADD',
                    "CREATE GROUP"),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text('CANCEL'),
              )
            ],
          )
        ],
      ),
    );
  }
}
