import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme  {
  AppTheme._();

  static const Color primary = Color(0xFFF05D23);
  static const Color onPrimary = Color(0xFFF2FDFF);
  static const Color secondary = Color(0xE6101935);
  static const Color onSecondary = Color(0xFFF2FDFF);
  static const Color error = Color(0xFF93032E);
  static const Color onError = Color(0xFFF2FDFF);

  static const Color surface = Color(0xFF28666E);
  static const Color onSurface = Color(0xFFF2FDFF);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
    ),
    scaffoldBackgroundColor: surface,
    textTheme: GoogleFonts.juraTextTheme().apply(
      bodyColor: onPrimary,
      displayColor: onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        textStyle: TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  );
}
