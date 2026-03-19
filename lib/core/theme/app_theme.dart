import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0x0D1117FF); // GitHub Dark
  static const Color surface = Color(0x161B22FF);
  static const Color primary = Color(0x58A6FFFF);
  static const Color secondary = Color(0x3FB950FF);
  static const Color accent = Color(0xBC8CFFFF);
  static const Color error = Color(0xF85149FF);
  static const Color textBody = Color(0xC9D1D9FF);
  static const Color textHeader = Color(0xF0F6FCFF);

  static ColorScheme get _colorScheme => ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        error: error,
        onSurface: textBody,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textBody,
        displayColor: textHeader,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textHeader,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary),
        ),
      ),
    );
  }
}
