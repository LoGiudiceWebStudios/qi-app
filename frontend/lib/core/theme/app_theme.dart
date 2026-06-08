import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Costruttore privato per evitare che la classe venga istanziata
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'Open Sauce',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE9B416),
      brightness: Brightness.dark,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFE9B416),
      selectionColor: Color(0xFFE9B416),
      selectionHandleColor: Color(0xFFE9B416),
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Open Sauce',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE9B416),
      brightness: Brightness.light,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFE9B416),
      selectionColor: Color(0xFFE9B416),
      selectionHandleColor: Color(0xFFE9B416),
    ),
    useMaterial3: true,
  );
}
