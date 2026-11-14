import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ========= Renkler (Grok tarzı koyu, mor-mavi gradient) =========
  static const Color primary = Color(0xFF7C3AED);       // Mor
  static const Color primaryLight = Color(0xFFA855F7);  // Açık mor
  static const Color secondary = Color(0xFF06B6D4);     // Cyan
  static const Color accent = Color(0xFFEC4899);        // Pembe
  static const Color gold = Color(0xFFF59E0B);          // Altın
  static const Color green = Color(0xFF10B981);         // Yeşil
  
  static const Color bgDark = Color(0xFF0A0A0F);        // Çok koyu arkaplan
  static const Color bgDark2 = Color(0xFF13131F);       // Kart arkaplanı
  static const Color bgDark3 = Color(0xFF1C1C2E);       // İkincil kart
  static const Color surfaceDark = Color(0xFF1E1E30);
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradient listesi
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0F), Color(0xFF13131F), Color(0xFF1C1C2E)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1030), Color(0xFF0F1930)],
  );

  static const LinearGradient musicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
  );

  static const LinearGradient rideGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
  );

  // ========= Karanlık Tema =========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgDark2,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w900, fontSize: 32),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 28),
          displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: textMuted, fontSize: 12),
        ),
      ),
      cardTheme: CardTheme(
        color: bgDark2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primary.withOpacity(0.2), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgDark2,
        indicatorColor: primary.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryLight, fontWeight: FontWeight.w700, fontSize: 11, fontFamily: 'Nunito');
          }
          return const TextStyle(color: textMuted, fontWeight: FontWeight.w500, fontSize: 11, fontFamily: 'Nunito');
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryLight, size: 26);
          }
          return const IconThemeData(color: textMuted, size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgDark3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Nunito'),
        hintStyle: const TextStyle(color: textMuted, fontFamily: 'Nunito'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  // ========= Aydınlık Tema (koyu tabanlı) =========
  static ThemeData get lightTheme => darkTheme;
}
