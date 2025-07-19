import 'package:flutter/material.dart';

/// Modern Minimal Pastel Color Palette
class AppColors {
  // Light Theme Colors - Minimal Pastels
  static const Color lightPrimary = Color(0xFF6B73FF); // Soft purple
  static const Color lightPrimaryLight = Color(0xFF9BA3FF); // Lighter purple
  static const Color lightPrimaryDark = Color(0xFF5A63E6); // Darker purple

  static const Color lightSecondary = Color(0xFF64748B); // Neutral slate
  static const Color lightSecondaryLight = Color(0xFF94A3B8); // Light slate
  static const Color lightSecondaryDark = Color(0xFF475569); // Dark slate

  static const Color lightAccent = Color(0xFF10B981); // Soft emerald
  static const Color lightAccentLight = Color(0xFF34D399); // Light emerald
  static const Color lightAccentDark = Color(0xFF059669); // Dark emerald

  static const Color lightBackground = Color(0xFFFBFBFB); // Almost white
  static const Color lightBackgroundLight = Color(0xFFFFFFFF); // Pure white
  static const Color lightBackgroundDark = Color(0xFFF8F9FA); // Light gray

  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightSurfaceLight = Color(0xFFFEFEFE); // Off white
  static const Color lightSurfaceDark = Color(0xFFF1F5F9); // Very light gray

  static const Color lightTextPrimary = Color(0xFF1F2937); // Dark gray
  static const Color lightTextSecondary = Color(0xFF6B7280); // Medium gray
  static const Color lightTextTertiary = Color(0xFF9CA3AF); // Light gray
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF); // White

  static const Color lightBorder = Color(0xFFE5E7EB); // Very light gray
  static const Color lightBorderLight = Color(0xFFF3F4F6); // Almost white
  static const Color lightBorderDark = Color(0xFFD1D5DB); // Light gray

  // Dark Theme Colors - Dark Pastels
  static const Color darkPrimary = Color(0xFF8B5CF6); // Soft violet
  static const Color darkPrimaryLight = Color(0xFFA78BFA); // Light violet
  static const Color darkPrimaryDark = Color(0xFF7C3AED); // Dark violet

  static const Color darkSecondary = Color(0xFF64748B); // Neutral slate
  static const Color darkSecondaryLight = Color(0xFF94A3B8); // Light slate
  static const Color darkSecondaryDark = Color(0xFF475569); // Dark slate

  static const Color darkAccent = Color(0xFF06D6A0); // Soft teal
  static const Color darkAccentLight = Color(0xFF40E0D0); // Light teal
  static const Color darkAccentDark = Color(0xFF059669); // Dark teal

  static const Color darkBackground = Color(0xFF0F172A); // Very dark blue
  static const Color darkBackgroundLight = Color(0xFF1E293B); // Dark blue
  static const Color darkBackgroundDark = Color(0xFF020617); // Almost black

  static const Color darkSurface = Color(0xFF1E293B); // Dark blue
  static const Color darkSurfaceLight = Color(0xFF334155); // Medium dark blue
  static const Color darkSurfaceDark = Color(0xFF0F172A); // Very dark blue

  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Almost white
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color darkTextTertiary = Color(0xFF94A3B8); // Medium gray
  static const Color darkTextOnPrimary = Color(0xFFFFFFFF); // White

  static const Color darkBorder = Color(0xFF334155); // Dark gray
  static const Color darkBorderLight = Color(0xFF475569); // Medium dark gray
  static const Color darkBorderDark = Color(0xFF1E293B); // Very dark gray

  // Status colors (same for both themes)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dynamic colors that change based on theme
  static Color primary(bool isDark) => isDark ? darkPrimary : lightPrimary;
  static Color primaryLight(bool isDark) =>
      isDark ? darkPrimaryLight : lightPrimaryLight;
  static Color primaryDark(bool isDark) =>
      isDark ? darkPrimaryDark : lightPrimaryDark;

  static Color secondary(bool isDark) =>
      isDark ? darkSecondary : lightSecondary;
  static Color secondaryLight(bool isDark) =>
      isDark ? darkSecondaryLight : lightSecondaryLight;
  static Color secondaryDark(bool isDark) =>
      isDark ? darkSecondaryDark : lightSecondaryDark;

  static Color accent(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color accentLight(bool isDark) =>
      isDark ? darkAccentLight : lightAccentLight;
  static Color accentDark(bool isDark) =>
      isDark ? darkAccentDark : lightAccentDark;

  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color backgroundLight(bool isDark) =>
      isDark ? darkBackgroundLight : lightBackgroundLight;
  static Color backgroundDark(bool isDark) =>
      isDark ? darkBackgroundDark : lightBackgroundDark;

  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceLight(bool isDark) =>
      isDark ? darkSurfaceLight : lightSurfaceLight;
  static Color surfaceDark(bool isDark) =>
      isDark ? darkSurfaceDark : lightSurfaceDark;

  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiary(bool isDark) =>
      isDark ? darkTextTertiary : lightTextTertiary;
  static Color textOnPrimary(bool isDark) =>
      isDark ? darkTextOnPrimary : lightTextOnPrimary;

  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color borderLight(bool isDark) =>
      isDark ? darkBorderLight : lightBorderLight;
  static Color borderDark(bool isDark) =>
      isDark ? darkBorderDark : lightBorderDark;

  static Color cardBackground(bool isDark) =>
      isDark ? darkSurface : lightSurface;
  static Color cardBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color cardShadow(bool isDark) =>
      isDark ? const Color(0x33000000) : const Color(0x0F000000);

  static Color chatUserBubble(bool isDark) =>
      isDark ? darkPrimary : lightPrimary;
  static Color chatAssistantBubble(bool isDark) =>
      isDark ? darkSurfaceLight : lightSurfaceLight;
  static Color chatInputBackground(bool isDark) =>
      isDark ? darkSurface : lightSurfaceLight;
}

/// Modern Typography System
class AppTypography {
  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.2,
  );

  // Heading styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.5,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 1.5,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w500,
    fontSize: 10,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w500,
    fontSize: 8,
    height: 1.4,
  );
}

/// Modern Spacing System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Modern Border Radius System
class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}

/// Modern Shadows
class AppShadows {
  static List<BoxShadow> small(bool isDark) => [
        BoxShadow(
          color: AppColors.cardShadow(isDark),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> medium(bool isDark) => [
        BoxShadow(
          color: AppColors.cardShadow(isDark),
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -1,
        ),
      ];

  static List<BoxShadow> large(bool isDark) => [
        BoxShadow(
          color: AppColors.cardShadow(isDark),
          offset: const Offset(0, 10),
          blurRadius: 15,
          spreadRadius: -3,
        ),
      ];
}

/// Modern App Theme
class AppTheme {
  static ThemeData get lightTheme => _buildTheme(false);
  static ThemeData get darkTheme => _buildTheme(true);

  static ThemeData _buildTheme(bool isDark) => ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: AppColors.primary(isDark),
          onPrimary: AppColors.textOnPrimary(isDark),
          secondary: AppColors.secondary(isDark),
          onSecondary: AppColors.textOnPrimary(isDark),
          error: AppColors.error,
          onError: AppColors.textOnPrimary(isDark),
          surface: AppColors.surface(isDark),
          onSurface: AppColors.textPrimary(isDark),
        ),

        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface(isDark),
          foregroundColor: AppColors.textPrimary(isDark),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.headingLarge.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          iconTheme: IconThemeData(color: AppColors.textSecondary(isDark)),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: AppColors.cardBackground(isDark),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(AppBorderRadius.lg)),
            side: BorderSide(color: AppColors.cardBorder(isDark)),
          ),
          margin: const EdgeInsets.all(AppSpacing.sm),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(isDark),
            foregroundColor: AppColors.textOnPrimary(isDark),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent(isDark),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary(isDark),
            side: BorderSide(color: AppColors.border(isDark)),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            borderSide: BorderSide(color: AppColors.border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            borderSide: BorderSide(color: AppColors.border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            borderSide: BorderSide(color: AppColors.accent(isDark), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary(isDark),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary(isDark),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),

        // List Tile Theme
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          titleTextStyle: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          subtitleTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(isDark),
          ),
          iconColor: AppColors.textSecondary(isDark),
        ),

        // Divider Theme
        dividerTheme: DividerThemeData(
          color: AppColors.border(isDark),
          thickness: 1,
          space: 1,
        ),

        // Icon Theme
        iconTheme: IconThemeData(
          color: AppColors.textSecondary(isDark),
          size: 24,
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          displayMedium: AppTypography.displayMedium.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          displaySmall: AppTypography.displaySmall.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          headlineLarge: AppTypography.headingLarge.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          headlineMedium: AppTypography.headingMedium.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          headlineSmall: AppTypography.headingSmall.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          bodyLarge: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          bodyMedium: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          bodySmall: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(isDark),
          ),
          labelLarge: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
          labelMedium: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary(isDark),
          ),
          labelSmall: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary(isDark),
          ),
        ),

        // Scaffold Background
        scaffoldBackgroundColor: AppColors.background(isDark),
      );
}
