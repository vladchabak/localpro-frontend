import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────
  static const Color primary     = Color(0xFF0E5C5C); // deep teal
  static const Color primaryDeep = Color(0xFF0A4747);
  static const Color primarySoft = Color(0xFFE8F2F1);
  static const Color accent      = Color(0xFFD88A4E); // warm sand (Mediterranean)
  static const Color accentSoft  = Color(0xFFFBEFE2);

  // ── Ink (text) ─────────────────────────────────────────────────
  static const Color ink  = Color(0xFF0E1A1F); // primary text
  static const Color ink2 = Color(0xFF3F5660); // secondary text
  static const Color ink3 = Color(0xFF7C8C92); // tertiary / captions

  // ── Surface ────────────────────────────────────────────────────
  static const Color paper = Color(0xFFFBFAF7); // warm off-white background
  static const Color card  = Color(0xFFFFFFFF);
  static const Color line  = Color(0xFFE7ECEC); // dividers / borders

  // ── Semantic ───────────────────────────────────────────────────
  static const Color ok    = Color(0xFF1F9D6E); // available / success
  static const Color star  = Color(0xFFE0A82E); // rating stars
  static const Color error = Color(0xFFD93025);

  // ── Shimmer ────────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFFE7ECEC);
  static const Color shimmerHighlight = Color(0xFFF5F8F8);

  // ── Aliases (keep existing code compiling) ─────────────────────
  static const Color primary2      = primaryDeep;
  static const Color primaryDark   = primaryDeep;
  static const Color secondary     = ink;
  static const Color surface       = card;
  static const Color background    = paper;
  static const Color textPrimary   = ink;
  static const Color textSecondary = ink2;
  static const Color border        = line;
  static const Color success       = ok;
}
