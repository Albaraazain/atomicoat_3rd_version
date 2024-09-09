import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ALDColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color background = Color(0xFFF0F3F8);
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFFFFA94D);
  static const Color text = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color divider = Color(0xFFDFE6E9);

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFFBE76);
  static const Color error = Color(0xFFFF7675);
}

ThemeData aldTheme() {
  final baseTextTheme = GoogleFonts.poppinsTextTheme();

  return ThemeData(
    primaryColor: ALDColors.primary,
    scaffoldBackgroundColor: ALDColors.background,
    colorScheme: ColorScheme.light(
      primary: ALDColors.primary,
      secondary: ALDColors.accent,
      surface: ALDColors.surface,
      background: ALDColors.background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ALDColors.text,
      onBackground: ALDColors.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: ALDColors.text),
      titleTextStyle: GoogleFonts.inter(
        color: ALDColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    textTheme: TextTheme(
      displayLarge: baseTextTheme.displayLarge!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w300),
      displayMedium: baseTextTheme.displayMedium!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w300),
      displaySmall: baseTextTheme.displaySmall!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w300),
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w400),
      headlineMedium: baseTextTheme.headlineMedium!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w400),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w400),
      titleLarge: baseTextTheme.titleLarge!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w500),
      titleMedium: baseTextTheme.titleMedium!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w500),
      titleSmall: baseTextTheme.titleSmall!.copyWith(color: ALDColors.text, fontWeight: FontWeight.w500),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(color: ALDColors.text),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(color: ALDColors.text),
      bodySmall: baseTextTheme.bodySmall!.copyWith(color: ALDColors.textLight),
      labelLarge: baseTextTheme.labelLarge!.copyWith(color: ALDColors.textLight, fontWeight: FontWeight.w500),
      labelMedium: baseTextTheme.labelMedium!.copyWith(color: ALDColors.textLight, fontWeight: FontWeight.w500),
      labelSmall: baseTextTheme.labelSmall!.copyWith(color: ALDColors.textLight, fontWeight: FontWeight.w500),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ALDColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ALDColors.primary,
        side: BorderSide(color: ALDColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ALDColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ALDColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ALDColors.primary),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: GoogleFonts.inter(color: ALDColors.textLight),
      hintStyle: GoogleFonts.inter(color: ALDColors.textLight),
    ),
    dividerTheme: DividerThemeData(
      color: ALDColors.divider,
      thickness: 1,
      space: 24,
    ),
    iconTheme: IconThemeData(
      color: ALDColors.primary,
      size: 24,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ALDColors.primary,
      inactiveTrackColor: ALDColors.primary.withOpacity(0.3),
      thumbColor: ALDColors.primary,
      overlayColor: ALDColors.primary.withOpacity(0.1),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return ALDColors.primary;
        }
        return ALDColors.textLight;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return ALDColors.primary.withOpacity(0.5);
        }
        return ALDColors.textLight.withOpacity(0.3);
      }),
    ),
  );
}