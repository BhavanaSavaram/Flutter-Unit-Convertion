# UnitBridge (Flutter)

A simple Flutter app that converts a value between metric and imperial
units across three quantity kinds: Length, Weight, and Temperature
(e.g. Miles ↔ Kilometers, Kilograms ↔ Pounds, Fahrenheit ↔ Celsius).

## Project structure

```
lib/
  main.dart                        # App entry point (MaterialApp)
  screens/bridge_home_screen.dart  # UI: kind/unit pickers, input, result
  models/quantity_kind.dart        # QuantityKind enum + labels
  utils/conversion_calculator.dart # Pure conversion math (no UI dependency)
android/app/src/main/AndroidManifest.xml
pubspec.yaml                       # Package manifest / dependencies
```

## Running it

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   and confirm your setup with `flutter doctor`.
2. From this directory, run `flutter create .` once to generate the
   full platform scaffolding (android/ios/web run configs) around the
   existing `lib/` source.
3. Get dependencies: `flutter pub get`
4. Run on a connected device or simulator/emulator: `flutter run`

## Notes

- Conversion logic lives in `ConversionCalculator` (`lib/utils/conversion_calculator.dart`),
  separate from the widget tree, so it can be tested independently.
- Length/mass conversions route through a common base unit (meters /
  kilograms); temperature uses its own formula since it isn't ratio-based.
