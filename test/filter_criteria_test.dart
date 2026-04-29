import 'package:flutter_test/flutter_test.dart';
import 'package:etherealestate/core/models/filter_criteria.dart';

void main() {
  group('FilterCriteria', () {
    test('defaults is considered default', () {
      expect(FilterCriteria.defaults.isDefault, isTrue);
    });

    test('non-default propertyType makes isDefault false', () {
      const f = FilterCriteria(propertyType: 'Villa');
      expect(f.isDefault, isFalse);
    });

    test('non-default minBeds makes isDefault false', () {
      const f = FilterCriteria(minBeds: 3);
      expect(f.isDefault, isFalse);
    });

    test('non-default minPrice makes isDefault false', () {
      const f = FilterCriteria(minPrice: 1000000);
      expect(f.isDefault, isFalse);
    });

    test('non-default maxPrice makes isDefault false', () {
      const f = FilterCriteria(maxPrice: 5000000);
      expect(f.isDefault, isFalse);
    });

    test('query makes isDefault false', () {
      const f = FilterCriteria(query: 'DHA');
      expect(f.isDefault, isFalse);
    });

    test('all defaults returns isDefault true', () {
      const f = FilterCriteria();
      expect(f.isDefault, isTrue);
    });

    test('type alias returns propertyType', () {
      const f = FilterCriteria(propertyType: 'House');
      expect(f.type, 'House');
    });

    test('bedrooms alias returns minBeds', () {
      const f = FilterCriteria(minBeds: 4);
      expect(f.bedrooms, 4);
    });

    test('copyWith preserves unmodified fields', () {
      const original = FilterCriteria(
        query: 'test',
        minPrice: 1000000,
        maxPrice: 5000000,
        minBeds: 3,
        propertyType: 'House',
      );

      final updated = original.copyWith(query: 'new');

      expect(updated.query, 'new');
      expect(updated.minPrice, 1000000);
      expect(updated.maxPrice, 5000000);
      expect(updated.minBeds, 3);
      expect(updated.propertyType, 'House');
    });
  });
}