import 'package:flutter/material.dart';

class OperonTheme {
  static const bg = Color(0xFF06111D);
  static const panel = Color(0xFF0D1B2A);
  static const panel2 = Color(0xFF122438);
  static const teal = Color(0xFF25D0BE);
  static const blue = Color(0xFF5CA9FF);
  static const muted = Color(0xFF8EA4B8);

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: teal, secondary: blue, surface: panel),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xFF091624), indicatorColor: panel2),
    cardTheme: CardThemeData(color: panel, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
  );
}
