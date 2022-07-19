import 'dart:async';

import 'package:instadent/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper2 {
  static final DatabaseHelper2 _instance = new DatabaseHelper2.internal();

  factory DatabaseHelper2() => _instance;

  final String tableNote = 'MyLocalCart';
  final String columnId = 'id';
  final String columnProductId = 'product_id';
  final String columnQuantity = 'quantity';
  final String columnRate = 'rate';
  final String columnOfferPrice = 'offer_price';

  static late Database _db1;

  DatabaseHelper2.internal();

  Future<Database> get db1 async {
    if (_db1 != null) {
      return _db1;
    }
    _db1 = await initDb();

    return _db1;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'product.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableNote($columnId INTEGER PRIMARY KEY, $columnProductId TEXT,$columnQuantity TEXT, $columnRate TEXT, $columnOfferPrice TEXT)');
  }

  Future<int> saveProduct(ProductModal modal) async {
    var dbClient = await db1;
    var result = await dbClient.insert(tableNote, modal.toMap());
    return result;
  }

  Future<List> getAllProducts() async {
    var dbClient = await db1;
    var result = await dbClient.query(tableNote, columns: [
      columnId,
      columnProductId,
      columnQuantity,
      columnRate,
      columnOfferPrice
    ]);

    return result.toList();
  }

  Future<int> deleteProduct(int id) async {
    var dbClient = await db1;
    return await dbClient
        .delete(tableNote, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateProductQuantity(ProductModal modal) async {
    var dbClient = await db1;
    return await dbClient.update(tableNote, modal.toMap(),
        where: "$columnQuantity = ?", whereArgs: [modal.product_id]);
  }

  Future close() async {
    var dbClient = await db1;
    return dbClient.close();
  }
}
