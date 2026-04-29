import 'package:flutter_test/flutter_test.dart';
import 'package:etherealestate/core/models/filter_criteria.dart';
import 'package:etherealestate/core/models/property_model.dart';

void main() {
  group('PropertyModel', () {
    test('fromApiMap maps areaSqft to sqft', () {
      final model = PropertyModel.fromApiMap({
        'id': 'test-1',
        'title': 'Test House',
        'location': 'DHA, Lahore',
        'price': 'PKR 1 Cr',
        'imageUrl': 'https://example.com/img.jpg',
        'beds': 3,
        'baths': 2,
        'areaSqft': 1800,
        'type': 'House',
      });

      expect(model.sqft, '1800');
      expect(model.beds, '3');
      expect(model.baths, '2');
      expect(model.category, 'House');
    });

    test('toString includes all fields', () {
      final model = PropertyModel(
        id: 'test-1',
        title: 'Test',
        location: 'Lahore',
        price: 'PKR 1 Cr',
        imageUrl: 'https://x.com/img.jpg',
        beds: '3',
        baths: '2',
        sqft: '1800',
        category: 'House',
      );

      expect(model.toString(), contains('Test'));
      expect(model.toString(), contains('1800'));
    });
  });

  group('FilterCriteria', () {
    test('defaults is empty', () {
      expect(FilterCriteria.defaults.isDefault, true);
    });

    test('copyWith works', () {
      final original = FilterCriteria.defaults;
      final updated = original.copyWith(
        query: 'DHA',
        minPrice: 10000000,
      );

      expect(updated.query, 'DHA');
      expect(updated.minPrice, 10000000);
      expect(updated.maxPrice, null);
    });

    test('isDefault returns false when criteria set', () {
      final withQuery = FilterCriteria(query: 'test');
      expect(withQuery.isDefault, false);

      final withPrice = FilterCriteria(minPrice: 1000000);
      expect(withPrice.isDefault, false);
    });
  });

  group('PropertyModel copyWith', () {
    test('copyWith creates new instance with updated fields', () {
      final original = PropertyModel(
        id: '1',
        title: 'Original',
        location: 'Lahore',
        price: 'PKR 1 Cr',
        imageUrl: 'https://x.com/1.jpg',
        beds: '3',
        baths: '2',
        sqft: '1000',
      );

      final updated = original.copyWith(title: 'Updated', price: 'PKR 2 Cr');

      expect(updated.title, 'Updated');
      expect(updated.price, 'PKR 2 Cr');
      expect(updated.id, '1');
    });
  });

  group('PropertyModel equality', () {
    test('same id equals', () {
      final a = PropertyModel(
        id: '1',
        title: 'A',
        location: 'Lahore',
        price: 'PKR 1 Cr',
        imageUrl: 'https://x.com/a.jpg',
        beds: '3',
        baths: '2',
        sqft: '1000',
      );

      final b = PropertyModel(
        id: '1',
        title: 'B',
        location: 'Karachi',
        price: 'PKR 2 Cr',
        imageUrl: 'https://x.com/b.jpg',
        beds: '4',
        baths: '3',
        sqft: '2000',
      );

      expect(a, equals(b));
    });
  });
}