import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────
///  Engez – Centralised Color Palette
/// ─────────────────────────────────────────────
///
/// Dark colours are extracted from the existing app design.
/// Light colours are dummies — replace them whenever you're ready.
abstract class AppColors {
  // ── Dark Mode ──────────────────────────────
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF282828);
  static const darkSurfaceAlt = Color(0xFF1E1E1E);
  static const darkSurfaceHigh = Color(0xFF2A2A2A);

  static const darkPrimary = Color(0xFFE5A722);
  static const darkOnPrimary = Color(0xFFFFFCFC);

  static const darkTextPrimary = Color(0xFFFFFCFC);
  static const darkTextSecondary = Color(0xFFC6C6C6);
  static const darkTextMuted = Color(0xFFA0A0A0);
  static const darkTextHint = Color(0xFF6D6D6D);
  static const darkIconSecondary = Color(0xFF9CA3AF);
  static const darkDivider = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)

  static const darkProgressBg = Color(0xFFA0A0A0);
  static const darkDestructive = Color(0xFFEF5350); // red[400]

  // ── Light Mode (Dummy — replace with real values) ──
  static const lightBackground = Color(0xFFF5F5F5); // TODO: replace
  static const lightSurface = Color(0xFFFFFFFF); // TODO: replace
  static const lightSurfaceAlt = Color(0xFFF0F0F0); // TODO: replace
  static const lightSurfaceHigh = Color(0xFFE8E8E8); // TODO: replace

  static const lightPrimary = Color.fromARGB(255, 175, 118, 3); // TODO: replace
  static const lightOnPrimary = Color(0xFFFFFFFF); // TODO: replace

  static const lightTextPrimary = Color(0xFF1A1A1A); // TODO: replace
  static const lightTextSecondary = Color(0xFF555555); // TODO: replace
  static const lightTextMuted = Color(0xFF888888); // TODO: replace
  static const lightTextHint = Color(0xFFAAAAAA); // TODO: replace
  static const lightIconSecondary = Color(0xFF6B7280); // TODO: replace
  static const lightDivider = Color(0x1A000000); // TODO: replace

  static const lightProgressBg = Color(0xFFD0D0D0); // TODO: replace
  static const lightDestructive = Color(0xFFEF5350); // TODO: replace
}
