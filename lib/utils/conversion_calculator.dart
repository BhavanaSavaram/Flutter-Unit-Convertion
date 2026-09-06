import '../models/quantity_kind.dart';

/// All unit-conversion math, kept separate from the UI so it's testable
/// on its own (see test/widget_test.dart) without building any screens.
class ConversionCalculator {
  // Private constructor: prevents instantiation, since every member
  // below is `static` and belongs to the class itself, not an instance.
  ConversionCalculator._();

  /// Selectable units per kind, in the order shown in the From/To dropdowns.
  static const Map<QuantKind, List<String>> unitsByKind = {
    QuantKind.length: ['Miles', 'Kilometers', 'Feet', 'Meters'],
    QuantKind.mass: ['Pounds', 'Kilograms'],
    QuantKind.temperature: ['Fahrenheit', 'Celsius'],
  };

  // --- Length ---
  // Length units scaled through meters as a common base unit, instead of
  // a separate formula for every pair (Miles->Feet, Feet->Kilometers...).
  static const Map<String, double> _lengthUnitFactors = {
    'Miles': 1609.344, // 1 mile = 1609.344 meters
    'Kilometers': 1000, // 1 kilometer = 1000 meters
    'Feet': 0.3048, // 1 foot = 0.3048 meters
    'Meters': 1, // 1 meter = 1 meter (the base unit itself)
  };

  // --- Mass ---
  // Same base-unit trick as length, but using kilograms as the base.
  static const Map<String, double> _massUnitFactors = {
    'Pounds': 0.45359237, // 1 pound = 0.45359237 kilograms
    'Kilograms': 1, // 1 kilogram = 1 kilogram (the base unit itself)
  };

  /// Converts [value] from [sourceUnit] to [targetUnit] for the given
  /// [kind]. Named parameters avoid accidentally swapping the two units.
  static double convert({
    required QuantKind kind,
    required String sourceUnit,
    required String targetUnit,
    required double value,
  }) {
    // Route to the right conversion strategy depending on the kind.
    switch (kind) {
      case QuantKind.length:
        return _scaleThroughBase(value, sourceUnit, targetUnit, _lengthUnitFactors);
      case QuantKind.mass:
        return _scaleThroughBase(value, sourceUnit, targetUnit, _massUnitFactors);
      case QuantKind.temperature:
        // Temperature can't use the base-unit trick — see _convertTemperatureValue.
        return _convertTemperatureValue(value, sourceUnit, targetUnit);
    }
  }

  /// Scales [value] from [sourceUnit] to [targetUnit] through a shared
  /// base unit. Only valid for ratio-based units, not temperature.
  static double _scaleThroughBase(
    double value,
    String sourceUnit,
    String targetUnit,
    Map<String, double> toBaseFactors,
  ) {
    final sourceFactor = toBaseFactors[sourceUnit];
    final targetFactor = toBaseFactors[targetUnit];
    if (sourceFactor == null || targetFactor == null) {
      // Safety net: the UI only ever offers units from `unitsByKind`.
      throw ArgumentError('Unknown unit: $sourceUnit or $targetUnit');
    }
    // Step 1: convert the input value into the base unit (e.g. meters).
    final baseValue = value * sourceFactor;
    // Step 2: convert from the base unit into the requested target unit.
    return baseValue / targetFactor;
  }

  /// Converts a temperature [value] from [sourceUnit] to [targetUnit].
  /// Needs its own formula since C and F don't both start at zero.
  static double _convertTemperatureValue(double value, String sourceUnit, String targetUnit) {
    // If the two units are the same, there's nothing to convert.
    if (sourceUnit == targetUnit) return value;

    if (sourceUnit == 'Fahrenheit' && targetUnit == 'Celsius') {
      // Fahrenheit-to-Celsius: subtract 32, multiply by 5/9.
      return (value - 32) * 5 / 9;
    }
    if (sourceUnit == 'Celsius' && targetUnit == 'Fahrenheit') {
      // Celsius-to-Fahrenheit: multiply by 9/5, add 32.
      return (value * 9 / 5) + 32;
    }

    // Same safety net as _scaleThroughBase, for an unrecognized unit.
    throw ArgumentError('Unknown temperature unit: $sourceUnit or $targetUnit');
  }
}
