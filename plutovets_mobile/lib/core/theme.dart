import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFFADCF);
  static const Color primaryVariant = Color(0xFFFF8BB8);
  static const Color secondaryColor = Color(0xFF040038);
  static const Color secondaryVariant = Color(0xFF060050);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFF8FA);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF040038);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFFBDBDBD);

  static const Color divider = Color(0xFFFFE0E8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFFFF0F4);

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFADCF), Color(0xFF040038)],
    stops: [0.0, 1.0],
  );

  // Pet colors
  static const Color petDog = Color(0xFF795548);
  static const Color petCat = Color(0xFF9E9E9E);
  static const Color petRabbit = Color(0xFF8D6E63);
  static const Color petBird = Color(0xFF0288D1);
  static const Color petRodent = Color(0xFF689F38);

  // Booking status colors
  static const Color bookingPending = Color(0xFFFFA000);
  static const Color bookingConfirmed = Color(0xFF388E3C);
  static const Color bookingCancelled = Color(0xFFD32F2F);
  static const Color bookingCompleted = Color(0xFF1976D2);

  // Text Styles with new fonts
  static TextStyle get logoStyle => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get headlineStyle => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get subheadlineStyle => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get bodyStyle => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get captionStyle => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get buttonStyle => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryVariant,
        secondary: secondaryColor,
        secondaryContainer: secondaryVariant,
        surface: surface,
        background: background,
        error: error,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSurface: onSurface,
        onBackground: onBackground,
        onError: onError,
      ),
      textTheme: TextTheme(
        displayLarge: logoStyle,
        displayMedium: headlineStyle,
        displaySmall: subheadlineStyle,
        bodyLarge: bodyStyle,
        bodyMedium: bodyStyle,
        bodySmall: captionStyle,
        labelLarge: buttonStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: buttonStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: captionStyle,
        labelStyle: captionStyle,
      ),
    );
  }

  static Color getPetColor(String species) {
    switch (species.toLowerCase()) {
      case 'chien':
        return const Color(0xFF795548);
      case 'chat':
        return const Color(0xFF9E9E9E);
      case 'lapin':
        return const Color(0xFF8D6E63);
      case 'oiseau':
        return const Color(0xFF0288D1);
      case 'rongeur':
        return const Color(0xFF689F38);
      default:
        return primaryColor;
    }
  }
}
