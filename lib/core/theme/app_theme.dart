import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryDefault = Color(0xFF6C63FF);
  static const Color _secondaryDefault = Color(0xFFFF6584);

  static ThemeData lightTheme({Color? primaryColor}) {
    final primary = primaryColor ?? _primaryDefault;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );
    final textTheme = GoogleFonts.cairoTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData darkTheme({Color? primaryColor}) {
    final primary = primaryColor ?? _primaryDefault;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    final textTheme = GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1A1A2E),
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
    );
  }
}

class PresetTheme {
  final String id;
  final String nameEn;
  final String nameAr;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final List<Color> gradientColors;

  const PresetTheme({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.gradientColors,
  });

  static const List<PresetTheme> presets = [
    PresetTheme(
      id: 'date',
      nameEn: 'Date',
      nameAr: 'موعد',
      primaryColor: Color.fromARGB(255, 232, 183, 227),
      secondaryColor: Color.fromARGB(255, 178, 11, 184),
      icon: Icons.favorite_rounded,
      gradientColors: [
        Color.fromARGB(255, 229, 183, 232),
        Color.fromARGB(255, 212, 116, 212),
        Color.fromARGB(255, 184, 11, 138),
      ],
    ),

    PresetTheme(
      id: 'wedding',
      nameEn: 'Wedding',
      nameAr: 'زفاف',
      primaryColor: Color(0xFFE8D5B7),
      secondaryColor: Color(0xFFB8860B),
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFE8D5B7), Color(0xFFD4A574), Color(0xFFB8860B)],
    ),
    PresetTheme(
      id: 'vacation',
      nameEn: 'Vacation',
      nameAr: 'إجازة',
      primaryColor: Color(0xFF00D2FF),
      secondaryColor: Color(0xFF3A7BD5),
      icon: Icons.beach_access_rounded,
      gradientColors: [Color(0xFF00D2FF), Color(0xFF3A7BD5), Color(0xFF00D2FF)],
    ),
    PresetTheme(
      id: 'work',
      nameEn: 'Work',
      nameAr: 'عمل',
      primaryColor: Color(0xFF667EEA),
      secondaryColor: Color(0xFF764BA2),
      icon: Icons.work_rounded,
      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    PresetTheme(
      id: 'ramadan',
      nameEn: 'Ramadan',
      nameAr: 'رمضان',
      primaryColor: Color(0xFF1B5E20),
      secondaryColor: Color(0xFFFFC107),
      icon: Icons.mosque_rounded,
      gradientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFFFFC107)],
    ),
    PresetTheme(
      id: 'eid',
      nameEn: 'Eid',
      nameAr: 'عيد',
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFF006400),
      icon: Icons.celebration_rounded,
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFA000), Color(0xFF006400)],
    ),
  ];

  static PresetTheme? getById(String id) {
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
