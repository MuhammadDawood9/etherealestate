import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;
  static final Map<String, String> _memoryPrefs = {}; // In-memory fallback for Web

  Future<Database> get database async {
    _database ??= await _openDatabase(join(await getDatabasesPath(), 'ethereal_estate.db'));
    return _database!;
  }

  Future<Database> _openDatabase(String path) {
    return openDatabase(path, version: 6, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE saved_properties(id TEXT PRIMARY KEY, title TEXT, location TEXT, price TEXT, imageUrl TEXT, beds TEXT, baths TEXT, sqft TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)');
    await db.execute('CREATE TABLE bookings(id TEXT PRIMARY KEY, propertyId TEXT, propertyTitle TEXT, date TEXT, timeSlot TEXT, createdAt TEXT, status TEXT DEFAULT "pending")');
    await db.execute('CREATE TABLE preferences(key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('CREATE TABLE search_history(query TEXT PRIMARY KEY, searched_at DATETIME DEFAULT CURRENT_TIMESTAMP)');
    await db.execute('CREATE TABLE seller_listings(id TEXT PRIMARY KEY, title TEXT, location TEXT, price TEXT, imageUrl TEXT, beds TEXT, baths TEXT, sqft TEXT, category TEXT, description TEXT, seller_uid TEXT, status TEXT DEFAULT "available", image_paths TEXT DEFAULT "", created_at DATETIME DEFAULT CURRENT_TIMESTAMP)');
  }

  Future<void> _onUpgrade(Database db, int old, int next) async {
    if (old < 4) await db.execute('ALTER TABLE bookings ADD COLUMN status TEXT DEFAULT "pending"');
    if (old < 5) await db.execute('CREATE TABLE IF NOT EXISTS seller_listings(id TEXT PRIMARY KEY, title TEXT, location TEXT, price TEXT, imageUrl TEXT, beds TEXT, baths TEXT, sqft TEXT, category TEXT, description TEXT, seller_uid TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)');
    if (old < 6) {
      await db.execute('ALTER TABLE seller_listings ADD COLUMN status TEXT DEFAULT "available"');
      await db.execute('ALTER TABLE seller_listings ADD COLUMN image_paths TEXT DEFAULT ""');
    }
  }

  // --- Fixed/Added Methods ---

  Future<bool> isPropertySaved(String id) async {
    if (kIsWeb) return false; // 👈 Web Bypass
    final db = await database;
    final rows = await db.query(
      'saved_properties',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isNotEmpty;
  }

  Future<String?> getPreference(String key, {String? defaultValue}) async {
    if (kIsWeb) return _memoryPrefs[key] ?? defaultValue;
    final db = await database;
    final rows = await db.query('preferences', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) {
      return rows.first['value'] as String;
    }
    return defaultValue;
  }

  // --- Saved Properties ---

  Future<void> saveProperty(Map<String, dynamic> property) async {
    if (kIsWeb) return; // 👈 Web Bypass
    final db = await database;
    await db.insert('saved_properties', property, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeProperty(String id) async {
    if (kIsWeb) return; // 👈 Web Bypass
    final db = await database;
    await db.delete('saved_properties', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProperty(String id) async => removeProperty(id);

  Future<Set<String>> getSavedPropertyIds() async {
    if (kIsWeb) return <String>{}; // 👈 Web Bypass
    final db = await database;
    final rows = await db.query('saved_properties', columns: ['id']);
    return rows.map((r) => r['id'] as String).toSet();
  }

  Future<List<Map<String, dynamic>>> getSavedProperties() async {
    if (kIsWeb) return []; // 👈 Web Bypass
    final db = await database;
    return db.query('saved_properties', orderBy: 'timestamp DESC');
  }

  // --- Preferences & Search ---

  Future<void> setPreference(String key, String value) async {
    if (kIsWeb) {
      _memoryPrefs[key] = value;
      return;
    }
    final db = await database;
    await db.insert('preferences', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearSearchHistory() async {
    if (kIsWeb) return; // 👈 Web Bypass
    final db = await database;
    await db.delete('search_history');
  }

  Future<void> saveBooking(Map<String, dynamic> booking) async {
    if (kIsWeb) return; // 👈 Web Bypass
    final db = await database;
    await db.insert('bookings', booking, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    if (kIsWeb) return []; // 👈 Web Bypass
    final db = await database;
    return db.query('bookings', orderBy: 'createdAt DESC');
  }

  Future<List<String>> getSearchHistory() async {
    if (kIsWeb) return []; // 👈 Web Bypass
    final db = await database;
    final rows = await db.query('search_history', columns: ['query'], orderBy: 'searched_at DESC', limit: 10);
    return rows.map((r) => r['query'] as String).toList();
  }

  Future<void> saveSearchQuery(String query) async {
    if (kIsWeb) return; // 👈 Web Bypass
    final db = await database;
    await db.insert('search_history', {'query': query.trim()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSearchQuery(String query) async {
    if (kIsWeb) return; // 👈 Web Bypass
    final db = await database;
    await db.delete('search_history', where: 'query = ?', whereArgs: [query]);
  }

  // --- Seller Listings ---

  Future<void> addSellerListing(Map<String, dynamic> listing) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert('seller_listings', listing, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getSellerListings(String sellerUid) async {
    if (kIsWeb) return [];
    final db = await database;
    return db.query('seller_listings', where: 'seller_uid = ?', whereArgs: [sellerUid], orderBy: 'created_at DESC');
  }

  Future<void> deleteSellerListing(String id) async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('seller_listings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSellerListing(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    final db = await database;
    await db.update('seller_listings', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setListingStatus(String id, String status) async {
    if (kIsWeb) return;
    final db = await database;
    await db.update('seller_listings', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSellerBookings(String sellerUid) async {
    if (kIsWeb) return [];
    final db = await database;
    return db.rawQuery('''
      SELECT b.* FROM bookings b
      WHERE b.propertyId IN (SELECT id FROM seller_listings WHERE seller_uid = ?)
      ORDER BY b.createdAt DESC
    ''', [sellerUid]);
  }
}