import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ethereal_estate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table for saved properties (My Collection)
    await db.execute('''
      CREATE TABLE saved_properties(
        id TEXT PRIMARY KEY,
        title TEXT,
        location TEXT,
        price TEXT,
        imageUrl TEXT,
        beds TEXT,
        baths TEXT,
        sqft TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // CRUD Operations for Saved Properties
  Future<int> saveProperty(Map<String, dynamic> property) async {
    final db = await database;
    return await db.insert(
      'saved_properties',
      property,
      conflictAlgorithm: ConflictBehavior.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSavedProperties() async {
    final db = await database;
    return await db.query('saved_properties', orderBy: 'timestamp DESC');
  }

  Future<int> deleteProperty(String id) async {
    final db = await database;
    return await db.delete(
      'saved_properties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isPropertySaved(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_properties',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}
