/// The physical quantities this app can convert between. Each kind groups
/// a set of compatible units — see ConversionCalculator for the unit lists.
enum QuantKind {
  length,
  mass,
  temperature,
}

/// Adds a `.label` getter to QuantKind for its human-readable display
/// text, keeping it next to the enum instead of scattered in the UI code.
extension QuantKindLabel on QuantKind {
  /// Text shown to the user for this kind, e.g. in the segmented button.
  String get label {
    // Matches this enum value to its display label.
    switch (this) {
      case QuantKind.length:
        return 'Length';
      case QuantKind.mass:
        return 'Weight';
      case QuantKind.temperature:
        return 'Temperature';
    }
  }
}
