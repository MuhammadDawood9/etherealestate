import 'package:flutter_test/flutter_test.dart';
import 'package:etherealestate/core/models/booking_model.dart';

void main() {
  group('BookingModel', () {
    const model = BookingModel(
      id: 'booking_001',
      propertyId: 'prop_001',
      propertyTitle: 'The Test Villa',
      date: '2026-06-15',
      timeSlot: '10:30 AM',
      createdAt: '2026-04-17T10:00:00.000',
    );

    test('toMap produces correct keys', () {
      final map = model.toMap();
      expect(map['id'], 'booking_001');
      expect(map['propertyId'], 'prop_001');
      expect(map['propertyTitle'], 'The Test Villa');
      expect(map['date'], '2026-06-15');
      expect(map['timeSlot'], '10:30 AM');
      expect(map['createdAt'], '2026-04-17T10:00:00.000');
    });

    test('fromMap round-trips correctly', () {
      final map = model.toMap();
      final restored = BookingModel.fromMap(map);
      expect(restored.id, model.id);
      expect(restored.propertyId, model.propertyId);
      expect(restored.propertyTitle, model.propertyTitle);
      expect(restored.date, model.date);
      expect(restored.timeSlot, model.timeSlot);
      expect(restored.createdAt, model.createdAt);
    });

    test('formattedDate returns human-readable date', () {
      expect(model.formattedDate, '15 Jun 2026');
    });

    test('formattedDate handles single-digit day', () {
      const early = BookingModel(
        id: 'x',
        propertyId: 'x',
        propertyTitle: 'x',
        date: '2026-01-05',
        timeSlot: '09:00 AM',
        createdAt: '2026-01-01',
      );
      expect(early.formattedDate, '05 Jan 2026');
    });

    test('formattedDate handles malformed date gracefully', () {
      const bad = BookingModel(
        id: 'x',
        propertyId: 'x',
        propertyTitle: 'x',
        date: 'invalid',
        timeSlot: '09:00 AM',
        createdAt: '2026-01-01',
      );
      expect(bad.formattedDate, 'invalid');
    });
  });
}
