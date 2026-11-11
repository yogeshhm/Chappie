import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);

  static const Color accentCyan = Color(0xFF0EA5E9);
  static const Color accentIndigo = Color(0xFF6366F1);

  // Semantic Status Colors
  static const Color statusInterested = Color(0xFF10B981); // Emerald
  static const Color statusFollowUp = Color(0xFFF59E0B); // Amber
  static const Color statusNotCalled = Color(0xFF64748B); // Slate
  static const Color statusNoAnswer = Color(0xFF8B5CF6); // Purple
  static const Color statusNotInterested = Color(0xFFEF4444); // Red
  static const Color statusClosedWon = Color(0xFF059669); // Dark Green

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF3B82F6);

  // Caution Banner
  static const Color cautionBg = Color(0xFFFFFBEB);
  static const Color cautionBorder = Color(0xFFFCD34D);
  static const Color cautionText = Color(0xFF92400E);

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentIndigo,
      surface: Color(0xFF1E293B), // Slate 800
      error: Color(0xFFF87171),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFF1F5F9),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accentIndigo,
      surface: Colors.white,
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0F172A),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.5,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
  );

  // Helper badge color getters
  static Color getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('interested') && !lower.contains('not')) {
      return statusInterested;
    } else if (lower.contains('follow')) {
      return statusFollowUp;
    } else if (lower.contains('won') || lower.contains('closed')) {
      return statusClosedWon;
    } else if (lower.contains('no answer') || lower.contains('busy')) {
      return statusNoAnswer;
    } else if (lower.contains('not interested') || lower.contains('invalid')) {
      return statusNotInterested;
    } else {
      return statusNotCalled;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
      default:
        return priorityLow;
    }
  }
}
