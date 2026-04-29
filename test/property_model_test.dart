import 'package:flutter_test/flutter_test.dart';
import 'package:etherealestate/core/models/property_model.dart';

void main() {
  group('PropertyModel', () {
    const model = PropertyModel(
      id: 'test_001',
      title: 'Test Villa',
      location: 'Paris, France',
      price: '\$3,000,000',
      imageUrl: 'https://example.com/img.jpg',
      beds: '4',
      baths: '3',
      sqft: '3,200',
      category: 'Villa',
    );

    test('toMap produces correct keys', () {
      final map = model.toMap();
      expect(map['id'], 'test_001');
      expect(map['title'], 'Test Villa');
      expect(map['location'], 'Paris, France');
      expect(map['price'], '\$3,000,000');
      expect(map['beds'], '4');
      expect(map['baths'], '3');
      expect(map['sqft'], '3,200');
      expect(map['imageUrl'], 'https://example.com/img.jpg');
    });

    test('fromMap round-trips correctly', () {
      final map = model.toMap();
      final restored = PropertyModel.fromMap(map);
      expect(restored.id, model.id);
      expect(restored.title, model.title);
      expect(restored.location, model.location);
      expect(restored.price, model.price);
      expect(restored.beds, model.beds);
      expect(restored.baths, model.baths);
      expect(restored.sqft, model.sqft);
      expect(restored.imageUrl, model.imageUrl);
    });

    test('default category is House', () {
      const minimal = PropertyModel(
        id: 'x',
        title: 'x',
        location: 'x',
        price: 'x',
        imageUrl: 'x',
        beds: '1',
        baths: '1',
        sqft: '100',
      );
      expect(minimal.category, 'House');
    });
  });
}
