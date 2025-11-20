import 'package:flutter/material.dart';

/// Theme configuration cho ứng dụng học tiếng Anh
/// Sử dụng tông xanh dương nhẹ chủ đạo
class AppTheme {
  // Private constructor để prevent instantiation
  AppTheme._();

  // Định nghĩa màu sắc chủ đạo - Gen Z & Kid Friendly
  static const Color primaryBlue = Color(0xFF5EB1FF);      // Softer, brighter blue
  static const Color lightBlue = Color(0xFF96D4FF);        // Very light blue
  static const Color paleBlue = Color(0xFFF0F8FF);         // Almost white blue
  static const Color accentPink = Color(0xFFFF6B9D);       // Playful pink
  static const Color accentYellow = Color(0xFFFFD93D);     // Bright yellow
  static const Color accentPurple = Color(0xFFA78BFA);     // Soft purple
  static const Color textDark = Color(0xFF2D3748);         // Softer dark
  static const Color textGrey = Color(0xFF94A3B8);         // Lighter grey
  static const Color successGreen = Color(0xFF4ADE80);     // Brighter green
  static const Color errorRed = Color(0xFFFF6B9D);         // Softer red (pink)
  static const Color warningYellow = Color(0xFFFFD93D);    // Bright cheerful yellow

  // Định nghĩa ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme FIX – sử dụng fromSeed để tránh thiếu field
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentPink,
        error: errorRed,
        surface: Colors.white,
      ),

      // Scaffold background
      scaffoldBackgroundColor: paleBlue,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryBlue),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ElevatedButton theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // OutlinedButton theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2.5),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // TextButton theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // InputDecoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2.5),
        ),
        labelStyle: const TextStyle(color: textGrey),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIconColor: primaryBlue,
        suffixIconColor: primaryBlue,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textGrey,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: primaryBlue, size: 24),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
    );
  }

  // Helper methods để tạo các widget tái sử dụng

  /// Container với border xanh nhạt
  static BoxDecoration lightBlueContainer() {
    return BoxDecoration(
      color: paleBlue,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: lightBlue.withValues(alpha: 0.3), width: 2),
    );
  }

  /// Container với background trắng và shadow nhẹ
  static BoxDecoration whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Tạo info box với icon và text
  static Widget infoBox({
    required IconData icon,
    required String text,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? paleBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (backgroundColor ?? paleBlue).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
