import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // DANA Signature Brand Colors
  // ==========================================
  static const Color primaryBlue = Color(0xFF118EEA);      // Official DANA Cerulean Blue
  static const Color primaryDark = Color(0xFF0C75C2);      // Deep DANA Blue
  static const Color primaryLight = Color(0xFFE8F4FD);     // Ultra Soft Blue Surface
  static const Color accentCyan = Color(0xFF00B4D8);       // Sky Cyan
  static const Color accentGreen = Color(0xFF00B074);      // DANA Success Green
  static const Color accentOrange = Color(0xFFFF8B00);     // DANA Amber Warning
  static const Color accentRed = Color(0xFFF43F5E);        // DANA Crimson Rose
  static const Color accentPurple = Color(0xFF7C3AED);     // Indigo Violet

  // Pastel Squircle Service Grid Colors (Fintech Style)
  static const Color pastelBlue = Color(0xFFE8F4FD);
  static const Color pastelGreen = Color(0xFFE6F9F0);
  static const Color pastelOrange = Color(0xFFFFF4E5);
  static const Color pastelRed = Color(0xFFFEECEE);
  static const Color pastelPurple = Color(0xFFF3E8FF);
  static const Color pastelCyan = Color(0xFFE0F7FA);
  static const Color pastelTeal = Color(0xFFE0F2F1);
  static const Color pastelAmber = Color(0xFFFEF9C3);

  // Backgrounds & Surface
  static const Color bgLight = Color(0xFFF5F8FB);          // Clean Soft Ice-Blue / Light Grey
  static const Color cardLight = Colors.white;             // Pure Crisp White
  static const Color borderLight = Color(0xFFE6EEF5);       // Subtle Clean Border

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Dark Mode Surface Colors
  static const Color bgDark = Color(0xFF0B132B);          // Deep Midnight Navy
  static const Color cardDark = Color(0xFF1C2541);        // Clean Navy Card
  static const Color surfaceDark = Color(0xFF111C38);     // Midnight Surface
  static const Color borderDark = Color(0xFF2E3E61);      // Subtle Navy Border

  // Header Gradient (Signature DANA App Header)
  static const LinearGradient danaHeaderGradient = LinearGradient(
    colors: [Color(0xFF118EEA), Color(0xFF0C75C2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Modern DANA Card Decoration
  static BoxDecoration cardDecoration(BuildContext context, {Color? accentColor, bool isSelected = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? cardDark : cardLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected && accentColor != null
            ? accentColor
            : (isDark ? borderDark : borderLight),
        width: isSelected ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.35)
              : (accentColor?.withOpacity(0.08) ?? const Color(0x0A0F172A)),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Light Theme (DANA Official Vibe)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: accentCyan,
        surface: cardLight,
        error: accentRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        color: cardLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: primaryBlue.withOpacity(0.35),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: accentCyan,
        surface: cardDark,
        error: accentRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        color: cardDark,
      ),
    );
  }
}
