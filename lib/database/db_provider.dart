import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tarea8/models/post_model.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null){
      return _database;
    }

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tarea8.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE posts ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "title TEXT,"
          "post_date DATETIME,"
          "description TEXT,"
          "image TEXT,"
          "audio TEXT"
          ")");
    });
  }

  storePost(Posts newPost) async {
    final db = await database;
    final formattedDate = DateFormat('yyyyMMdd').format(newPost.date);
    var res = await db?.rawInsert(
      "INSERT Into posts (title, post_date, description, image, audio)"
      " VALUES (${newPost.title},'$formattedDate',${newPost.description},${newPost.image},${newPost.audio})");
    return res;
  }

  Future<List<Posts>> getAllPosts() async {
    final db = await database;
    var res = await db?.query("posts");
    List<Posts> posts =
        (res??[]).isNotEmpty ? res!.map((c) => Posts.fromJson(c)).toList() : <Posts>[];
    return posts;
  }

  Future<int> deleteAll() async {
    final db = await database;
    db?.rawDelete("Delete from posts");
    return 1;
  }
}