// Widget smoke tests — verify key screens render without crashing.
// Screens that require Firebase are tested via their sub-widgets to avoid
// platform channel setup in the test runner.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etherealestate/core/models/filter_criteria.dart';
import 'package:etherealestate/core/models/property_model.dart';
import 'package:etherealestate/shared/widgets/glass_card.dart';
import 'package:etherealestate/shared/widgets/shimmer_box.dart';

void main() {
  group('GlassCard', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(child: Text('hello')),
          ),
        ),
      );
      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('ShimmerBox', () {
    testWidgets('renders without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, height: 200, child: ShimmerBox()),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('FilterCriteria widget integration', () {
    testWidgets('defaults do not crash when displayed', (tester) async {
      final criteria = FilterCriteria.defaults;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              criteria.isDefault ? 'Default' : 'Filtered',
            ),
          ),
        ),
      );
      expect(find.text('Default'), findsOneWidget);
    });
  });

  group('PropertyModel display', () {
    testWidgets('renders property title correctly', (tester) async {
      const property = PropertyModel(
        id: 'p1',
        title: 'Ocean Villa',
        location: 'Malibu',
        price: '\$3,000,000',
        imageUrl: 'https://example.com/img.jpg',
        beds: '4',
        baths: '3',
        sqft: '3,200',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(property.title),
                Text(property.location),
                Text(property.price),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Ocean Villa'), findsOneWidget);
      expect(find.text('Malibu'), findsOneWidget);
      expect(find.text('\$3,000,000'), findsOneWidget);
    });
  });
}
