import 'package:flutter/material.dart';

/// Trazzo brand color – used across the app with white.
const Color TrazzoPrimary = Color(0xFF00ADFF);

/// App theme: white and #00ADFF (Trazzo blue).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: TrazzoPrimary,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        surfaceContainerHighest: const Color(0xFFF5F5F5),
        outline: Colors.grey.shade400,
        error: Colors.red.shade700,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: TrazzoPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TrazzoPrimary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: TrazzoPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: TrazzoPrimary, width: 2),
        ),
        focusColor: TrazzoPrimary,
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) return TrazzoPrimary;
          return Colors.grey;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: TrazzoPrimary,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TrazzoPrimary,
        foregroundColor: Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return TrazzoPrimary;
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TrazzoPrimary,
        circularTrackColor: Color(0xFFE0F4FF),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade800,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: TrazzoPrimary,
      ),
    );
  }
}
