import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// "Asphalt & Signal" theme — Phase 2
// Light theme only; dark theme is out of scope (REQUIREMENTS.md Out of Scope).
// All hex values are the canonical UI-SPEC §Color palette.
// ---------------------------------------------------------------------------

const _surface = Color(0xFF1C1F26); // dominant 60%
const _surfaceVariant = Color(0xFF2A2D36); // secondary 30%
const _primary = Color(0xFFF5A623); // accent 10% — F5A623
const _onSurface = Color(0xFFFFFFFF); // primary text
const _onSurfaceVariant = Color(0xFFE0E0E0); // secondary text
const _error = Color(0xFFE53935);
const _outlineVariant = Color(0xFF3D4050); // dividers

/// Asphalt & Signal MaterialApp theme.
///
/// Wire via `MaterialApp.router(theme: appTheme)`.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    // Primary / accent
    primary: _primary,
    onPrimary: _surface,
    // Surface hierarchy
    surface: _surface,
    onSurface: _onSurface,
    // Variant surfaces (cards, search field fills)
    surfaceContainerHighest: _surfaceVariant,
    onSurfaceVariant: _onSurfaceVariant,
    // Error
    error: _error,
    onError: _onSurface,
    // Outline / divider
    outlineVariant: _outlineVariant,
    // Secondary (unused; satisfy required parameter)
    secondary: _primary,
    onSecondary: _surface,
    // Tertiary (unused)
    tertiary: _surfaceVariant,
    onTertiary: _onSurface,
    // Additional required params
    secondaryContainer: _surfaceVariant,
    onSecondaryContainer: _onSurface,
    primaryContainer: _surfaceVariant,
    onPrimaryContainer: _onSurface,
    tertiaryContainer: _surfaceVariant,
    onTertiaryContainer: _onSurface,
    errorContainer: _error,
    onErrorContainer: _onSurface,
    surfaceDim: _surface,
    surfaceBright: _surfaceVariant,
    surfaceContainerLowest: _surface,
    surfaceContainerLow: _surface,
    surfaceContainer: _surfaceVariant,
    inverseSurface: _onSurface,
    onInverseSurface: _surface,
    inversePrimary: _primary,
    outline: _outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
  ),
  scaffoldBackgroundColor: _surface,
  cardColor: _surfaceVariant,
  // ---------------------------------------------------------------------------
  // Typography — Inter via google_fonts, body 16/400, label 18/400, heading 20/600
  // Only Regular (400) and SemiBold (600); no fontSize below 16.
  // ---------------------------------------------------------------------------
  textTheme: GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  ).copyWith(
    // body — 16/400
    bodyMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _onSurface,
      height: 1.5,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _onSurface,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 16, // never below 16
      fontWeight: FontWeight.w400,
      color: _onSurfaceVariant,
      height: 1.5,
    ),
    // label — 18/400
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: _onSurface,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: _onSurface,
      height: 1.4,
    ),
    // heading — 20/600
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _onSurface,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _onSurface,
      height: 1.3,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: _onSurface,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _onSurfaceVariant,
    ),
  ),
  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------
  appBarTheme: AppBarTheme(
    backgroundColor: _surfaceVariant,
    foregroundColor: _onSurface,
    elevation: 0,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _onSurface,
    ),
    iconTheme: const IconThemeData(color: _onSurface, size: 24),
  ),
  // ---------------------------------------------------------------------------
  // ElevatedButton — 56 dp height, full width, accent fill
  // ---------------------------------------------------------------------------
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: _surface,
      minimumSize: const Size(double.infinity, 56),
      textStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  // ---------------------------------------------------------------------------
  // TextButton — accent label
  // ---------------------------------------------------------------------------
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _primary,
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  // ---------------------------------------------------------------------------
  // ListTile — 56 dp minimum height
  // ---------------------------------------------------------------------------
  listTileTheme: const ListTileThemeData(
    minVerticalPadding: 8,
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
    tileColor: Colors.transparent,
  ),
  // ---------------------------------------------------------------------------
  // Divider
  // ---------------------------------------------------------------------------
  dividerTheme: const DividerThemeData(
    color: _outlineVariant,
    thickness: 1,
    space: 0,
    indent: 16,
    endIndent: 0,
  ),
  // ---------------------------------------------------------------------------
  // Input / TextField fill
  // ---------------------------------------------------------------------------
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surfaceVariant,
    hintStyle: GoogleFonts.inter(
      fontSize: 16,
      color: _onSurfaceVariant,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  // ---------------------------------------------------------------------------
  // Chip (used by CarChip)
  // ---------------------------------------------------------------------------
  chipTheme: ChipThemeData(
    backgroundColor: _primary,
    labelStyle: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: _surface,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
);
