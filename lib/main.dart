// Entry point of every Dart/Flutter app; main() starts it.
import 'package:flutter/material.dart';

import 'screens/conv_home_screen.dart';

void main() {
  // runApp() draws this widget tree on screen and keeps it updated.
  runApp(const UnitConvApp());
}

/// Root widget of the app: sets up the title, theme, and first screen.
class UnitConvApp extends StatelessWidget {
  // StatelessWidget: no changing data, built once.
  const UnitConvApp({super.key});

  // build() returns the widget tree Flutter should render.
  @override
  Widget build(BuildContext context) {
    // MaterialApp wires up Material Design: theming, fonts, navigation.
    return MaterialApp(
      title: 'UnitConvertion', // Shown in the OS task switcher, not on-screen.
      debugShowCheckedModeBanner: false, // Hides the red "DEBUG" ribbon in the corner.
      theme: ThemeData(
        // Generates a full color palette from one seed color.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true, // Opt in to the newer Material 3 visual style.
      ),
      // First screen shown on launch; the actual UI lives in
      // conv_home_screen.dart, keeping this file to app-level setup only.
      home: const ConvHomeScreen(),
    );
  }
}
