import 'dart:io' as io;

import 'package:myapp/sqflite/NotesModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notes.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreat);
    return db;
  }

  _onCreat(Database db, int version) async {
    await db.execute(CREATNOTESTABLE);
  }

  Future<NotesModel> insertTable(NotesModel notesModel) async {
    var dbClient = await db;
    dbClient!.insert("notes", notesModel.toMap());
    return notesModel;
  }

  Future<int> deleteTable(int id) async {
    var dbClient = await db;
    return await dbClient!.delete("notes", where: "id = ?", whereArgs: [id]);
  }

  Future<int> UpdateTable(NotesModel notesModel) async {
    var dbClient = await db;
    return await dbClient!.update(
      "notes",
      notesModel.toMap(),
      where: "id = ?",
      whereArgs: [notesModel.id],
    );
  }

  Future<List<NotesModel>> getNotesList() async {
    var dbClient = await db;
    List<Map<String, Object?>> queryResult = await dbClient!.query("notes");

    return queryResult.map((e) => NotesModel.fromMap(e)).toList();
  }
}

const CREATNOTESTABLE = ''' 
CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,
age INTEGER NOT NULL,description TEXT NOT NULL,email TEXT)
''';
