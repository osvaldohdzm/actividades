import 'dart:io';
import 'package:Actividades/models/protocol.dart';
import 'package:Actividades/models/proyect.dart';
import 'package:Actividades/models/subtaks.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/Item.dart';
import 'models/todolist.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  Database _db;
  DatabaseHelper.internal();
  final String databaseName = "Database";
  final String databaseFileName = "TestDB.db";

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await initDB(databaseName);
    return _db;
  }

  Future<String> getUrl() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseFileName);
    debugPrint("Database location: " + path); // Print database location
    return path;
  }

  replaceDB(String fullPathDatabase) async {
    _db = await openDatabase(fullPathDatabase);
    return _db;
  }

  initDB(String dbName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseFileName);

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE lists ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "name TEXT,"
          "order_index INTEGER,"
          "tasks_sort TEXT,"
          "color TEXT"
          ")");

      await db.execute("CREATE TABLE subtasks ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "task_id INTEGER,"
          "repetition_days INTEGER,"
          "description TEXT,"
          "due_date DATETIME,"
          "title INTEGER,"
          "order_index INTEGER"
          ")");

      await db.execute("CREATE TABLE protocols ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "name TEXT,"
          "description TEXT,"
          "order_index INTEGER"
          ")");

      await db.execute("CREATE TABLE proyects ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "name TEXT,"
          "description TEXT,"
          "background_image TEXT,"
          "members_group TEXT,"
          "status INTEGER,"
          "order_index INTEGER"
          ")");

      await db.execute("CREATE TABLE notifications ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "task_id INTEGER,"
          "name TEXT,"
          "date_time DATETIME,"
          "description TEXT"
          ")");

      await db.execute("CREATE TABLE tasks ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "list_id INTEGER,"
          "done INTEGER,"
          "title TEXT,"
          "due_date DATETIME,"
          "repetition_days INTEGER,"
          "description TEXT"
          ")");
    });
  }

  Future<List<Todolist>> getAllLists() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM lists ORDER BY order_index ASC");
    debugPrint("maps value: " + maps.toString());
    if (maps.length > 0) {
      return List.generate(maps.length, (i) {
        return Todolist(
            id: maps[i]['id'],
            name: maps[i]['name'],
            color: maps[i]['color'],
            tasksSort: maps[i]['tasks_sort'],
            orderIndex: maps[i]['order_index']);
      });
    } else {
      return [];
    }
  }

  Future<Todolist> getList(String name) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM lists WHERE name=?", [name]);
    if (maps.length > 0) {
      List my = List.generate(maps.length, (i) {
        String nm = maps[i]['name'];
        return Todolist(
            id: maps[i]['id'],
            name: nm,
            tasksSort: maps[i]['tasks_sort'],
            color: maps[i]['color'],
            orderIndex: maps[i]['order_index']);
      });
      return my[0];
    } else {
      return Todolist();
    }
  }

  Future<Todolist> getListById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM lists WHERE id=?", [id]);
    // print(maps.length);
    if (maps.length > 0) {
      List my = List.generate(maps.length, (i) {
        // print(nm);
        return Todolist(
            id: maps[i]['id'],
            name: maps[i]['name'],
            tasksSort: maps[i]['tasks_sort'],
            color: maps[i]['color'],
            orderIndex: maps[i]['order_index']);
      });
      return my[0];
    } else {
      // print('bingo');
      return Todolist();
    }
  }

  Future<int> createList(String listName, int l) async {
    // print('bingo');
    final db = await database;
    Todolist temp = Todolist(
        id: l, name: listName, color: 'Red', orderIndex: l, tasksSort: 'DESC');

    return await db.insert('lists', temp.toMap());
  }

/*
  Future<int> updateSubtasks(List<Subtask> subtask, int taskId) async {
 
    final db = await database;

   // await db.delete(table);

    //for ();
  
    return await db.insert(databaseName, temp.toMap());
  }
*/
  Future<List<Protocol>> getAllProtocols() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM protocols ORDER BY order_index ASC");
    print("tratanto de obtener protocols" + maps.length.toString());
    if (maps.length > 0) {
      return List.generate(maps.length, (i) {
        // print(i);
        return Protocol(
            id: maps[i]['id'],
            name: maps[i]['name'],
            description: maps[i]['description'],
            orderIndex: maps[i]['order_index']);
      });
    } else {
      // print('bingo');
      return [];
    }
  }

  Future<List<Protocol>> getAllProyectTasks() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM protocols ORDER BY orderIndex ASC");
    print("tratanto de obtener proyectask" + maps.length.toString());
    if (maps.length > 0) {
      return List.generate(maps.length, (i) {
        // print(i);
        return Protocol(
            id: maps[i]['id'],
            name: maps[i]['name'],
            description: maps[i]['description'],
            orderIndex: maps[i]['order_index']);
      });
    } else {
      // print('bingo');
      return [];
    }
  }

  Future<List<Proyect>> getAllProyects() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM proyects ORDER BY order_index ASC");
    // print(maps.length);
    if (maps.length > 0) {
      return List.generate(maps.length, (i) {
        // print(i);
        return Proyect(
            id: maps[i]['id'],
            name: maps[i]['name'],
            description: maps[i]['description'],
            orderIndex: maps[i]['order_index'],
            status: maps[i]['status'],
            membersGroup: maps[i]['members_group'],
            backgroundImage: maps[i]['background_image']);
      });
    } else {
      // print('bingo');
      return [];
    }
  }

  Future<Proyect> getProyect(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM proyects WHERE id=?", [id]);
    // print(maps.length);
    if (maps.length > 0) {
      List my = List.generate(maps.length, (i) {
        return Proyect(
            id: maps[i]['id'],
            name: maps[i]['name'],
            description: maps[i]['description'],
            orderIndex: maps[i]['order_index'],
            status: maps[i]['status'],
            membersGroup: maps[i]['members_group'],
            backgroundImage: maps[i]['background_image']);
      });
      return my[0];
    } else {
      // print('bingo');
      return Proyect();
    }
  }

  Future<Protocol> getProtocol(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM protocols WHERE id=?", [id]);
    // print(maps.length);
    if (maps.length > 0) {
      List my = List.generate(maps.length, (i) {
        // print(i);
        String nm = maps[i]['name'];
        // print(nm);
        return Protocol(
            id: maps[i]['id'],
            name: nm,
            description: maps[i]['description'],
            orderIndex: maps[i]['order_index']);
      });
      return my[0];
    } else {
      // print('bingo');
      return Protocol();
    }
  }

  Future<int> newProtocol(
      String protocolName, String description, int l) async {
    final db = await database;
    Protocol temp = Protocol(
        id: l, name: protocolName, description: description, orderIndex: l);
    return await db.insert("protocols", temp.toMap());
  }

  Future<int> updateProcotol(Protocol protocol) async {
    debugPrint("Update protocol to: " +
        protocol.name +
        protocol.description.toString());

    final db = await database;
    return await db.update("protocols", protocol.toMap(),
        where: "id = ?", whereArgs: [protocol.id]);
  }

  Future<void> deleteProtocol(int protocolId) async {
    final db = await database;
    // print('deleted successfully');
    db.delete("protocols", where: "id = ?", whereArgs: [protocolId]);
  }

  Future<int> newProyect(String protocolName, String description, int l) async {
    final db = await database;
    Proyect temp = Proyect(
        id: l, name: protocolName, description: description, orderIndex: l);
    return await db.insert("proyects", temp.toMap());
  }

  Future<int> updateProyect(Proyect protocol) async {
    debugPrint("Update protocol to: " +
        protocol.name +
        protocol.description.toString());

    final db = await database;
    return await db.update("proyects", protocol.toMap(),
        where: "id = ?", whereArgs: [protocol.id]);
  }

  Future<void> deleteProyect(int protocolId) async {
    final db = await database;
    // print('deleted successfully');
    db.delete("proyects", where: "id = ?", whereArgs: [protocolId]);
  }

  Future<int> updateList(Todolist list) async {
    debugPrint("Update list values: " +
        list.name +
        " " +
        list.tasksSort +
        " " +
        list.orderIndex.toString());
    final db = await database;
    Todolist oldlist = await getListById(list.id);
    final String oldname = oldlist.name;
    final String newname = list.name;

    if (oldname != newname) {
      oldlist.name = newname;
    }

    return await db.update('lists', list.toMap(),
        where: "id = ?", whereArgs: [oldlist.id]);
  }

  Future<List<Item>> getListItems(
      int listId, String sortOrder, String ascdesc) async {
    debugPrint("Obtenerde la base de datos: " +
        listId.toString() +
        sortOrder +
        ascdesc);
    final Database db = await database;

    //final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM '$listName' ORDER BY '$sortOrder' '$ascdesc'");
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM tasks WHERE list_id='$listId' ORDER BY '$sortOrder' $ascdesc");

    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        done: maps[i]['done'],
        title: maps[i]['title'],
        description: maps[i]['description'],
      );
    });
  }

  Future<Item> getItem(int myid) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT id, title, description, done FROM tasks WHERE id='$myid'");

    List<Item> mylist = List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        done: maps[i]['done'],
        title: maps[i]['title'],
        description: maps[i]['description'],
      );
    });
    return mylist[0];
  }

  Future<int> newItem(Item newItem) async {
    print('Inserting :' + newItem.title);
    final db = await database;
    return await db.insert("tasks", newItem.toMap());
    // print('inserted successfully!');
    // return res;
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    debugPrint("Update item value : " +
        item.id.toString() +
        " " +
        item.listId.toString());
    return await db.update("tasks", item.toMap(),
        where: "id = ?",
        whereArgs: [item.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future close() async {
    final db = await database;

    return db.close();
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    // print('deleted successfully');
    db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }

  deleteAll(String listName) async {
    final db = await database;
    db.rawDelete("DELETE FROM \"$listName\"");
  }

  deleteList(int listId) async {
    final db = await database;
    // print("deleting: $listName , id: $id");
    await db.delete('lists', where: "id = ?", whereArgs: [listId]);
  }
}

//The entry in database are not in quotes
// But the names of the table are in quotes
