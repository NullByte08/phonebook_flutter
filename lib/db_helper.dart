import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phonebook/contacts.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database _db;
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String ADDRESS = 'address';
  static const String CONTACTNUMBER = 'contactnumber';
  static const String TABLENAME = 'Contact';
  static const String DB_NAME = 'contact.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  getDatabase() {
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLENAME ($ID INTEGER PRIMARY KEY, $NAME TEXT, $CONTACTNUMBER NUMBER, $ADDRESS TEXT)");
  }

  Future<Contact> save(Contact contact) async {
    var dbClient = await db;
    contact.id = await dbClient.insert(TABLENAME, contact.toMap());
    return contact;
    /*await dbClient.transaction((txn) async{
      var query = "INSERT INTO $TABLENAME ($NAME) VALUES ('"+ contact.name + "')";
      return await txn.rawInsert(query);
    });*/
  }

  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(TABLENAME, columns: [ID, NAME, ADDRESS, CONTACTNUMBER]);
    List<Contact> contacts = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        contacts.add(Contact.fromMap(maps[i]));
      }
    }
    return contacts;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLENAME, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> update(Contact contact) async {
    var dbClient = await db;
    return await dbClient.update(TABLENAME, contact.toMap(),
        where: '$ID = ?', whereArgs: [contact.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
