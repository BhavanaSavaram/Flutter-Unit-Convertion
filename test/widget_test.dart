import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unit_convertion/main.dart';
import 'package:unit_convertion/models/quantity_kind.dart';
import 'package:unit_convertion/utils/conversion_calculator.dart';

void main() {
  group('ConversionCalculator', () {
    test('converts miles to kilometers', () {
      final result = ConversionCalculator.convert(
        kind: QuantKind.length,
        sourceUnit: 'Miles',
        targetUnit: 'Kilometers',
        value: 1,
      );
      expect(result, closeTo(1.609344, 0.0001));
    });

    test('converts kilograms to pounds', () {
      final result = ConversionCalculator.convert(
        kind: QuantKind.mass,
        sourceUnit: 'Kilograms',
        targetUnit: 'Pounds',
        value: 1,
      );
      expect(result, closeTo(2.2046226, 0.0001));
    });

    test('converts Fahrenheit to Celsius', () {
      final result = ConversionCalculator.convert(
        kind: QuantKind.temperature,
        sourceUnit: 'Fahrenheit',
        targetUnit: 'Celsius',
        value: 32,
      );
      expect(result, closeTo(0, 0.0001));
    });
  });

  group('ConvHomeScreen', () {
    testWidgets('shows a result after entering a value and tapping Convert',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConvApp());

      // Default kind is Length (Miles -> Kilometers).
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Convert'));
      await tester.pump();

      expect(find.textContaining('Miles = '), findsOneWidget);
    });
  });
}
