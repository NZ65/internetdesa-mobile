import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Zenless Zone Zero (ZZZ) Urban Street Anime Design System
class AppTheme {
  // ZZZ Core Palette
  static const Color bgDark = Color(0xFF0E0F14);          // Deep Matte Carbon Black
  static const Color bgSurface = Color(0xFF161820);       // Dark Slate Surface
  static const Color bgCard = Color(0xFF1E212B);          // Tactical Carbon Card
  static const Color bgCardLight = Color(0xFF282C3A);     // Elevated Highlight Card

  // Neon & Hazard Accents
  static const Color neonCyan = Color(0xFF00F0FF);        // Electric Neon Cyan
  static const Color hazardYellow = Color(0xFFFFCC00);    // Cyber Hazard Yellow
  static const Color accentOrange = Color(0xFFFF6600);    // Vibrant Action Orange
  static const Color neonGreen = Color(0xFF00E676);       // Online / Normal Emerald
  static const Color crimsonRed = Color(0xFFFF3366);      // LOS / Critical / Alert
  static const Color electricPurple = Color(0xFFB026FF);  // Tech Purple

  // Text Colors
  static const Color textWhite = Color(0xFFF8FAFC);       // Crisp Pure White
  static const Color textSilver = Color(0xFFCBD5E1);      // High-contrast Silver
  static const Color textMuted = Color(0xFF8692A6);       // Subdued Slate
  static const Color textDark = Color(0xFF4B5563);        // Dimmed Detail

  // Borders & Glows
  static const Color borderDark = Color(0xFF2A2D3C);
  static const Color borderCyan = Color(0x4D00F0FF);
  static const Color borderYellow = Color(0x4DFFCC00);

  // Backward-compatibility aliases for legacy screen references
  static const Color primaryBlue = neonCyan;
  static const Color primaryCyan = neonCyan;
  static const Color primaryDark = Color(0xFF0C75C2);
  static const Color primaryNavy = bgDark;
  static const Color techCyan = neonCyan;
  static const Color iceBackground = bgDark;
  static const Color textMain = textWhite;
  static const Color textLight = textSilver;
  static const Color cardLight = bgCard;
  static const Color cardDark = bgCard;
  static const Color bgCardElevated = bgCardLight;
  static const Color borderLight = borderDark;
  static const Color borderSubtle = borderDark;
  static const Color accentGreen = neonGreen;
  static const Color accentYellow = hazardYellow;
  static const Color accentRed = crimsonRed;
  static const Color accentPurple = electricPurple;
  static const Color pastelGreen = Color(0x2200E676);
  static const Color pastelRed = Color(0x22FF3366);
  static const Color pastelOrange = Color(0x22FF6600);
  static const Color pastelPurple = Color(0x22B026FF);

  // ZZZ Cyber Shadows & Glows
  static const List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: Color(0x4400F0FF),
      blurRadius: 18,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> softShadow = cardShadow;

  static ThemeData get lightTheme => darkTheme;

  static ThemeData get darkTheme {
    final baseFont = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: neonCyan,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: hazardYellow,
        surface: bgSurface,
        background: bgDark,
        error: crimsonRed,
      ),
      textTheme: baseFont.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(color: textWhite, fontWeight: FontWeight.w900),
        titleLarge: GoogleFonts.plusJakartaSans(color: textWhite, fontWeight: FontWeight.w800, fontSize: 18),
        titleMedium: GoogleFonts.plusJakartaSans(color: textWhite, fontWeight: FontWeight.w700, fontSize: 16),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textWhite, fontSize: 14),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: neonCyan),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1.2),
        ),
      ),
    );
  }
}
