import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tp_android/models/todo.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todos.db';

    // Open/create the database at a given path
    var todosDatabase = await openDatabase(
        path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE todolist(id INTEGER PRIMARY KEY AUTOINCREMENT, texte TEXT)');
  }


  Future<List<ToDo>> todolist() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('todolist');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return ToDo(
        maps[i]['id'],
        maps[i]['texte'],
      );
    });
  }

  Future<int> insertTodo(ToDo todo) async {
    Database db = await this.database;
    var result = await db.insert(
        'todolist', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<int> deleteTodo(int id) async {
    var db = await this.database;
    int result = await db.delete('todolist', where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future<int> deleteAllTodo() async {
    var db = await this.database;
    int result = await db.delete('todolist');
    return result;
  }

  }