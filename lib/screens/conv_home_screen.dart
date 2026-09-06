import 'package:flutter/material.dart';

import '../models/quantity_kind.dart';
import '../utils/conversion_calculator.dart';

/// Main screen: pick a kind, pick from/to units, enter a value, and see
/// the result. Split into ConvHomeScreen (blueprint) and its State (data).
class ConvHomeScreen extends StatefulWidget {
  const ConvHomeScreen({super.key});

  // Creates the mutable State object for this widget.
  @override
  State<ConvHomeScreen> createState() => _ConvHomeScreenState();
}

/// Holds the screen's mutable data and builds its widget tree. The
/// leading underscore makes it private to this file, as State classes are.
class _ConvHomeScreenState extends State<ConvHomeScreen> {
  // Controls the text field so we can read what the user typed.
  final TextEditingController _valController = TextEditingController();

  // --- These fields are the screen's "state" ---
  // Changing any of these inside setState() tells Flutter to redraw.

  QuantKind _selectedKind = QuantKind.length; // Currently selected kind.
  late String _sourceUnit; // Currently selected "convert from" unit.
  late String _targetUnit; // Currently selected "convert to" unit.
  String? _outputText; // Text to show in the result card, or null if no result yet.
  String? _validationError; // Validation error message, or null if the input is fine.
  // `_sourceUnit`/`_targetUnit` are `late`: set in initState(), not here.
  // `_outputText`/`_validationError` are nullable: "none yet" is valid.

  /// Sets initial values before the first build. Must stay named
  /// `initState` (Flutter's exact lifecycle hook) — renaming it crashes the app.
  @override
  void initState() {
    super.initState();
    // Default kind starts on its first two units (Miles -> Kilometers).
    final availableUnits = ConversionCalculator.unitsByKind[_selectedKind]!;
    _sourceUnit = availableUnits[0];
    _targetUnit = availableUnits[1];
  }

  /// Disposes the text controller to avoid a memory leak when the
  /// screen is removed.
  @override
  void dispose() {
    _valController.dispose();
    super.dispose();
  }

  /// Runs when the user picks a different kind. Resets both unit
  /// selections, since the old units may not exist in the new kind.
  void _handleKindChanged(QuantKind? newKind) {
    if (newKind == null) return; // Defensive check; shouldn't happen in practice.
    final availableUnits = ConversionCalculator.unitsByKind[newKind]!;
    // setState() tells Flutter to rebuild with the new values below.
    setState(() {
      _selectedKind = newKind;
      _sourceUnit = availableUnits[0];
      _targetUnit = availableUnits[1];
      _outputText = null; // Clear any old result, since it's now stale.
      _validationError = null;
    });
  }

  /// Swaps the "from" and "to" units when the ⇄ button is tapped.
  void _handleSwapUnits() {
    setState(() {
      final previousSource = _sourceUnit;
      _sourceUnit = _targetUnit;
      _targetUnit = previousSource;
      _outputText = null; // Old result was for the un-swapped direction, so clear it.
    });
  }

  /// Runs when the user taps the "Convert" button.
  void _handleConvertPressed() {
    final enteredText = _valController.text.trim();
    // tryParse returns null instead of crashing on invalid input.
    final parsedValue = double.tryParse(enteredText);

    if (parsedValue == null) {
      // Input wasn't a valid number — show an error instead of a result.
      setState(() {
        _validationError = 'Enter a valid number';
        _outputText = null;
      });
      return;
    }

    // Delegates the math to ConversionCalculator, kept separate for testing.
    final result = ConversionCalculator.convert(
      kind: _selectedKind,
      sourceUnit: _sourceUnit,
      targetUnit: _targetUnit,
      value: parsedValue,
    );

    setState(() {
      _validationError = null;
      // Build a human-readable sentence like "10 Miles = 16.0934 Kilometers".
      _outputText = '${_formatDisplayValue(parsedValue)} $_sourceUnit = '
          '${_formatDisplayValue(result)} $_targetUnit';
    });
  }

  /// Formats a number: whole numbers show no decimals, else 4 places.
  String _formatDisplayValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(4);
  }

  /// Builds this screen's widget tree; rebuilds on every setState() call.
  @override
  Widget build(BuildContext context) {
    // Units valid for the current kind, for the From/To dropdowns.
    final availableUnits = ConversionCalculator.unitsByKind[_selectedKind]!;

    return Scaffold(
      // Basic screen layout: app bar on top, body below.
      appBar: AppBar(title: const Text('UnitConv')),
      body: SingleChildScrollView(
        // Scroll view keeps the screen usable when the keyboard pops up.
        padding: const EdgeInsets.all(24),
        child: Column(
          // Column stacks children vertically; stretch fills full width.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Kind selector (Length / Weight / Temperature) ---
            // SegmentedButton forces exactly one choice. Icons were removed:
            // no room for icon + checkmark + "Temperature" without wrapping.
            SegmentedButton<QuantKind>(
              segments: QuantKind.values
                  .map((kind) => ButtonSegment(
                        value: kind,
                        label: Text(kind.label),
                      ))
                  .toList(),
              selected: {_selectedKind},
              // Highlight color already shows selection; skip the checkmark.
              showSelectedIcon: false,
              // Smaller font keeps "Temperature" on one line.
              style: SegmentedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 13),
              ),
              // Selection is never empty, so .first is always safe.
              onSelectionChanged: (selection) => _handleKindChanged(selection.first),
            ),
            const SizedBox(height: 24), // Simple vertical spacing gap.

            // --- "From" dropdown, swap button, "To" dropdown ---
            Row(
              // Row lays out its children horizontally.
              children: [
                Expanded(
                  // Expanded shares remaining width evenly between the dropdowns.
                  child: DropdownButtonFormField<String>(
                    initialValue: _sourceUnit,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: availableUnits
                        .map((unitName) => DropdownMenuItem(value: unitName, child: Text(unitName)))
                        .toList(),
                    // Update just _sourceUnit and redraw when the user picks a new value.
                    onChanged: (value) => setState(() => _sourceUnit = value!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap units', // Shown on long-press/hover for accessibility.
                  onPressed: _handleSwapUnits,
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _targetUnit,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: availableUnits
                        .map((unitName) => DropdownMenuItem(value: unitName, child: Text(unitName)))
                        .toList(),
                    onChanged: (value) => setState(() => _targetUnit = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Numeric value entry field ---
            TextField(
              controller: _valController,
              // Number-friendly keyboard; allows decimals and a minus sign.
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: 'Value',
                border: const OutlineInputBorder(),
                // Shows the validation message (if any) right under the field.
                errorText: _validationError,
              ),
            ),
            const SizedBox(height: 24),

            // --- Convert button ---
            ElevatedButton(
              onPressed: _handleConvertPressed,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Convert', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),

            // --- Result card ---
            // Shown only once there's a result; `if` inside a list literal.
            if (_outputText != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _outputText!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
