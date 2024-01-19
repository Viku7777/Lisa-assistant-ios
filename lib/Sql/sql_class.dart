import 'dart:convert';

import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper {
  // function to create a table
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
  CREATE TABLE allChats(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  data TEXT
  )
  """);
  }

  // function to create a database
  static Future<sql.Database> db() async {
    return sql.openDatabase("allChatsHistory.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  // function to create a item in table
  static Future<int> createItem(String question, String message) async {
    final db = await SqlHelper.db();
    // final data = {"message": message};

    var sendData = jsonEncode({
      "question": question,
      "msgList": [
        {"content": question, "role": "user"},
        {"content": message, "role": "assistant"},
      ]
    });
    Map<String, Object> data = {"data": sendData};
    final id = await db.insert("allChats", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  // function to update a single item
  static Future<int> updateItem(
      int id, String question, String message, List allMessage) async {
    final db = await SqlHelper.db();

    // print(allMessage);
    var valuData = allMessage.firstWhere((e) => e['id'] == id)['data'];

    List allList =
        (jsonDecode(valuData) as Map<String, dynamic>)["msgList"] as List;

    allList.addAll([
      {"content": question, "role": "user"},
      {"content": message, "role": "assistant"},
    ]);

    var sendData = jsonEncode({
      "question": jsonDecode(valuData)["question"],
      "msgList": allList
      // "msgList": [
      //   allList,
      //   {"content": question, "role": "user"},
      //   {"content": message, "role": "assistant"},
      // ]
    });

    Map<String, Object> data = {"data": sendData};
    final result =
        await db.update("allChats", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // function to get all allChats
  static Future<List<Map<String, dynamic>>> getchatItems() async {
    final db = await SqlHelper.db();
    return db.query("allChats", orderBy: "id");
  }

  // function to get single item with the help of id
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlHelper.db();
    return db.query("allChats", where: "id = ?", whereArgs: [id], limit: 1);
  }

  // function to delete item by id
  static Future<void> deleteItem(int id) async {
    final db = await SqlHelper.db();
    try {
      await db.delete("allChats", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Something went wrong when deleting an item $e");
    }
  }

  // function to delete chat table
  static Future<void> deleteTable() async {
    var db = await SqlHelper.db();

    try {
      await db.delete("allChats");
    } catch (e) {
      print("Something went wrong when deleting table $e");
    }
  }
}
