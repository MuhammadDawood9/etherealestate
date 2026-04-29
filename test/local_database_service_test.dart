import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:etherealestate/core/services/local_database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalDatabaseService', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
    });

    test('singleton pattern works', () {
      final db2 = LocalDatabaseService();
      expect(identical(db, db2), isTrue);
    });

    test('database is initialized lazily', () async {
      final database = await db.database;
      expect(database, isNotNull);
    });

    test('saveProperty and getSavedProperties round-trips', () async {
      final property = {
        'id': 'test_001',
        'title': 'Test Villa',
        'location': 'Lahore',
        'price': 'PKR 1 Cr',
        'imageUrl': 'https://example.com/img.jpg',
        'beds': '4',
        'baths': '3',
        'sqft': '3200',
      };
      await db.saveProperty(property);
      final saved = await db.getSavedProperties();
      expect(saved.length, 1);
      expect(saved.first['id'], 'test_001');
      expect(saved.first['title'], 'Test Villa');
    });

    test('deleteProperty removes the record', () async {
      await db.saveProperty({
        'id': 'del_001',
        'title': 'D',
        'location': 'Lahore',
        'price': 'PKR 1 Cr',
        'imageUrl': 'U',
        'beds': '1',
        'baths': '1',
        'sqft': '100',
      });
      final before = await db.getSavedProperties();
      expect(before.any((p) => p['id'] == 'del_001'), isTrue);
      
      await db.removeProperty('del_001');
      final after = await db.getSavedProperties();
      expect(after.any((p) => p['id'] == 'del_001'), isFalse);
    });

    test('saveBooking and getBookings round-trips', () async {
      final booking = {
        'id': 'book_001',
        'propertyId': 'prop_001',
        'propertyTitle': 'Test Villa',
        'date': '2026-06-15',
        'timeSlot': '10:30 AM',
      };
      await db.saveBooking(booking);
      final bookings = await db.getBookings();
      expect(bookings.length, 1);
      expect(bookings.first['id'], 'book_001');
    });
  });
}