import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.app,
      onPrimary: Colors.white,
      secondary: AppColors.mid,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      margin: const EdgeInsets.only(bottom: 10),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    fontFamily: 'Inter',
  );
}
