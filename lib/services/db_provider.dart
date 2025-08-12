import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/offer.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await init();
    return _database!;
  }

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'alerts.db');
    _database = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE offers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          offerId TEXT,
          source TEXT,
          title TEXT,
          url TEXT,
          thumbnail TEXT,
          currentPrice INTEGER,
          currency TEXT,
          lastSeen TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE price_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          offerId TEXT,
          price INTEGER,
          ts TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE filters (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source TEXT,
          query TEXT,
          maxPrice INTEGER,
          city TEXT
        )
      ''');
    });
  }

  Future<int> upsertOffer(Map<String,dynamic> m) async {
    final db = await database;
    // try find by offerId+source
    final rows = await db.query('offers', where: 'offerId = ? AND source = ?', whereArgs: [m['offerId'], m['source']]);
    if (rows.isEmpty) {
      return await db.insert('offers', m);
    } else {
      final id = rows.first['id'] as int;
      await db.update('offers', m, where: 'id = ?', whereArgs: [id]);
      return id;
    }
  }

  Future<void> addPriceHistory(String offerId, int price, String ts) async {
    final db = await database;
    await db.insert('price_history', {'offerId': offerId, 'price': price, 'ts': ts});
  }

  Future<List<Map<String,dynamic>>> getOffers() async {
    final db = await database;
    return await db.query('offers', orderBy: 'lastSeen DESC');
  }

  Future<List<Map<String,dynamic>>> getHistory(String offerId) async {
    final db = await database;
    return await db.query('price_history', where: 'offerId = ?', whereArgs: [offerId], orderBy: 'ts ASC');
  }

  Future<List<Map<String,dynamic>>> getFilters() async {
    final db = await database;
    return await db.query('filters');
  }

  Future<int> saveFilter(Map<String,dynamic> f) async {
    final db = await database;
    return await db.insert('filters', f);
  }

  Future<int> updateFilter(int id, Map<String,dynamic> f) async {
    final db = await database;
    return await db.update('filters', f, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFilter(int id) async {
    final db = await database;
    return await db.delete('filters', where: 'id = ?', whereArgs: [id]);
  }
}
