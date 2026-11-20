import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Blue Archive & DANA Inspired
  static const Color primaryBlue = Color(0xFF118EEA);      // Cerulean Blue (DANA Core)
  static const Color primaryDark = Color(0xFF0C75C2);      // Deep Cyber Blue
  static const Color primaryNavy = Color(0xFF0A192F);      // Dark NOC Navy
  static const Color techCyan = Color(0xFF00E5FF);         // Cyber Tech Cyan (Blue Archive Halo)
  static const Color iceBackground = Color(0xFFF5F8FB);    // DANA Ice Blue Background
  
  // Neutral & Accent Tones
  static const Color textMain = Color(0xFF1E293B);         // Slate 800
  static const Color textMuted = Color(0xFF64748B);        // Slate 500
  static const Color textLight = Color(0xFF94A3B8);        // Slate 400
  
  // Status Colors
  static const Color accentGreen = Color(0xFF00C853);       // Emerald Green (Online / Lunas)
  static const Color pastelGreen = Color(0xFFE8F5E9);
  static const Color accentRed = Color(0xFFFF3B30);         // Crimson Alert (LOS / Offline / Terisolir)
  static const Color pastelRed = Color(0xFFFFEBEE);
  static const Color accentOrange = Color(0xFFFF9500);      // Amber Pending / Unpaid
  static const Color pastelOrange = Color(0xFFFFF3E0);
  static const Color accentPurple = Color(0xFF7C4DFF);      // Tech Purple
  static const Color pastelPurple = Color(0xFFEDE7F6);

  // Surface & Cards
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF16203B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Soft Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x080A192F),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cyberGlow = [
    BoxShadow(
      color: Color(0x33118EEA),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static ThemeData get lightTheme {
    final baseFont = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: iceBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: techCyan,
        surface: cardLight,
        background: iceBackground,
      ),
      textTheme: baseFont.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(color: textMain, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.plusJakartaSans(color: textMain, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: GoogleFonts.plusJakartaSans(color: textMain, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textMain, fontSize: 14),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x0D000000)),
        ),
      ),
    );
  }
}
