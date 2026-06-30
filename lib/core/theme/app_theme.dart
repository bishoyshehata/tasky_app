import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

/// ─────────────────────────────────────────────
///  Tasky – App Theme
/// ─────────────────────────────────────────────
///
/// [AppTheme.dark]  → current production design (extracted from the app).
/// [AppTheme.light] → dummy theme; replace AppColors.light* values when ready.
abstract class AppTheme {
  // ─────────────────────────── Dark ────────────────────────────
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: GoogleFonts.notoSans().fontFamily,

        // Core colours
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkOnPrimary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkSurfaceAlt,
          onSurfaceVariant: AppColors.darkTextSecondary,
          error: AppColors.darkDestructive,
          onError: AppColors.darkOnPrimary,
          outline: AppColors.darkDivider,
        ),

        scaffoldBackgroundColor: AppColors.darkBackground,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: AppSp.sp20,
            fontWeight: FontWeight.w500,
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        ),

        // Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.darkPrimary,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: AppColors.darkOnPrimary,
            disabledBackgroundColor: Color(0xFF0D7A47), // darkPrimary ~50%
            disabledForegroundColor: Color(0x80FFFCFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // IconButton (filled variant used in home screen)
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.darkSurface,
            foregroundColor: AppColors.darkTextPrimary,
          ),
        ),

        // Text Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          hintStyle: TextStyle(
            color: AppColors.darkTextHint,
            fontSize: AppSp.sp16,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.darkPrimary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.darkDestructive),
          ),
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(AppColors.darkOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          side: const BorderSide(color: AppColors.darkTextMuted),
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkPrimary;
            }
            return AppColors.darkSurfaceHigh;
          }),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
          space: 0,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkPrimary,
          contentTextStyle: TextStyle(color: AppColors.darkOnPrimary, fontFamily: GoogleFonts.notoSans().fontFamily,),
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Text
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: AppSp.sp16),
          bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontSize: AppSp.sp14),
          bodySmall: TextStyle(color: AppColors.darkTextMuted, fontSize: AppSp.sp12),
          titleLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: AppSp.sp24,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: AppSp.sp20,
            fontWeight: FontWeight.w500,
          ),
          labelLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: AppSp.sp16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  // ─────────────────────────── Light (Dummy) ───────────────────
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: GoogleFonts.notoSans().fontFamily,

        // TODO: swap AppColors.light* values with real brand colours

        colorScheme: const ColorScheme.light(
          brightness: Brightness.light,
          primary: AppColors.lightPrimary,
          onPrimary: AppColors.lightOnPrimary,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightSurfaceAlt,
          onSurfaceVariant: AppColors.lightTextSecondary,
          error: AppColors.lightDestructive,
          onError: AppColors.lightOnPrimary,
          outline: AppColors.lightDivider,
        ),

        scaffoldBackgroundColor: AppColors.lightBackground,

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: AppSp.sp20,
            fontWeight: FontWeight.w500,
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.lightPrimary,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: AppColors.lightOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.lightSurfaceHigh,
            foregroundColor: AppColors.lightTextPrimary,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurfaceAlt,
          hintStyle: TextStyle(
            color: AppColors.lightTextHint,
            fontSize: AppSp.sp16,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.lightPrimary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.lightDestructive),
          ),
        ),

        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(AppColors.lightOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          side: const BorderSide(color: AppColors.lightTextMuted),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimary;
            }
            return AppColors.lightSurfaceHigh;
          }),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.lightDivider,
          thickness: 1,
          space: 0,
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightPrimary,
          contentTextStyle: TextStyle(color: AppColors.lightOnPrimary, fontFamily: GoogleFonts.notoSans().fontFamily),
        ),

        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontSize: AppSp.sp16),
          bodyMedium: TextStyle(color: AppColors.lightTextSecondary, fontSize: AppSp.sp14),
          bodySmall: TextStyle(color: AppColors.lightTextMuted, fontSize: AppSp.sp12),
          titleLarge: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: AppSp.sp24,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: AppSp.sp20,
            fontWeight: FontWeight.w500,
          ),
          labelLarge: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: AppSp.sp16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}
