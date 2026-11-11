import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Canvas & Surfaces (Linear / Attio inspired deep obsidian)
  static const Color darkCanvas = Color(0xFF080B11); // Deepest obsidian void
  static const Color darkSurface = Color(0xFF0F1523); // Elevated primary surface
  static const Color darkSurfaceElevated = Color(0xFF151D30); // Card & panel surface
  static const Color darkSurfaceHighlight = Color(0xFF1C2740); // Active/Hover surface
  static const Color darkBorder = Color(0xFF1E2B45); // Precise hairline border
  static const Color darkBorderSubtle = Color(0xFF152033);

  // Light Canvas & Surfaces
  static const Color lightCanvas = Color(0xFFF6F8FB);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Brand Accents
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentViolet = Color(0xFF8B5CF6);

  // Semantic Status Colors
  static const Color emeraldHot = Color(0xFF10B981);
  static const Color amberFollowUp = Color(0xFFF59E0B);
  static const Color rosePriority = Color(0xFFF43F5E);
  static const Color purpleOutreach = Color(0xFF8B5CF6);
  static const Color slateMuted = Color(0xFF64748B);

  // Linear / Attio Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hotGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF111726), Color(0xFF0C101A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Avatar Monogram Gradients based on string hash
  static LinearGradient getAvatarGradient(String name) {
    final int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    final List<List<Color>> palettes = [
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)], // Blue
      [const Color(0xFF6366F1), const Color(0xFF4338CA)], // Indigo
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)], // Violet
      [const Color(0xFF06B6D4), const Color(0xFF0E7490)], // Cyan
      [const Color(0xFF10B981), const Color(0xFF047857)], // Emerald
      [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Amber
      [const Color(0xFFF43F5E), const Color(0xFFBE123C)], // Rose
    ];
    final selected = palettes[hash % palettes.length];
    return LinearGradient(
      colors: selected,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Dark Theme Definition
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkCanvas,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryIndigo,
      surface: darkSurface,
      surfaceContainerHighest: darkSurfaceElevated,
      error: rosePriority,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFF8FAFC),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCanvas,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.4,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorderSubtle,
      thickness: 1,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    ),
  );

  // Light Theme Definition
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightCanvas,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryIndigo,
      surface: lightSurface,
      surfaceContainerHighest: lightSurfaceElevated,
      error: rosePriority,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0F172A),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightCanvas,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.4,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
  );

  static Color getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('interested') && !lower.contains('not')) {
      return emeraldHot;
    } else if (lower.contains('follow')) {
      return amberFollowUp;
    } else if (lower.contains('won') || lower.contains('closed')) {
      return const Color(0xFF059669);
    } else if (lower.contains('no answer') || lower.contains('busy') || lower.contains('progress')) {
      return purpleOutreach;
    } else if (lower.contains('not interested') || lower.contains('invalid')) {
      return rosePriority;
    } else {
      return slateMuted;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return rosePriority;
      case 'medium':
        return amberFollowUp;
      case 'low':
      default:
        return primaryBlue;
    }
  }
}
