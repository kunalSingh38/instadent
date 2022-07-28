// import 'package:instadent/product_model.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   static final _databaseName = "cardb.db";
//   static final _databaseVersion = 1;

//   static final table = 'cars_table';

//   static final columnProductId = 'productId';
//   static final columnProductQty = 'productQty';
//   static final columnProductPrice = 'productPrice';
//   static final columnProductDisscount = 'productDisscount';

//   // make this a singleton class
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   // only have a single app-wide reference to the database
//   static Database? _database;
//   Future<Database?> get database async {
//     if (_database != null) return _database;
//     // lazily instantiate the db the first time it is accessed
//     _database = await _initDatabase();
//     return _database;
//   }

//   // this opens the database (and creates it if it doesn't exist)
//   _initDatabase() async {
//     String path = join(await getDatabasesPath(), _databaseName);
//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }

//   // SQL code to create the database table
//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//           CREATE TABLE $table (
//             $columnProductId TEXT NOT NULL,
//             $columnProductQty TEXT NOT NULL,
//             $columnProductPrice TEXT NOT NULL,
//             $columnProductDisscount TEXT NOT NULL
//           )
//           ''');
//   }

//   // Helper methods

//   // Inserts a row in the database where each key in the Map is a column name
//   // and the value is the column value. The return value is the id of the
//   // inserted row.
//   Future<int> insert(DummyCart car) async {
//     Database? db = await instance.database;
//     return await db!.insert(table, {
//       'productId': car.productId,
//       'productQty': car.productQty,
//       'productPrice': car.productPrice,
//       'productDisscount': car.productDisscount
//     });
//   }

//   // All of the rows are returned as a list of maps, where each map is
//   // a key-value list of columns.
//   Future<List<Map<String, dynamic>>> queryAllRows() async {
//     Database? db = await instance.database;
//     return await db!.query(table);
//   }

//   // // Queries rows based on the argument received
//   // Future<List<Map<String, dynamic>>> queryRows(name) async {
//   //   Database? db = await instance.database;
//   //   return await db!.query(table, where: "$columnName LIKE '%$name%'");
//   // }

//   Future<int> updateProductQuantity(DummyCart modal) async {
//     Database? db = await instance.database;

//     return await db!.update(table, modal.toMap(),
//         where: "$columnProductId = ?", whereArgs: [modal.productId]);
//   }

//   // // Deletes the row specified by the id. The number of affected rows is
//   // // returned. This should be 1 as long as the row exists.
//   Future<int> delete(int id) async {
//     Database? db = await instance.database;
//     return await db!
//         .delete(table, where: '$columnProductId = ?', whereArgs: [id]);
//   }

//   Future<int> deleteAll() async {
//     Database? db = await instance.database;
//     return await db!.delete(table);
//   }
// }
