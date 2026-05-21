import 'package:flutter/material.dart';

abstract final class DC {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0052FF);
  static const Color primaryActive = Color(0xFF003ECC);
  static const Color primaryDisabled = Color(0xFFA8B8CC);

  // ── Canvas / Surface ───────────────────────────────────────────────────────
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF7F7F7);
  static const Color surfaceStrong = Color(0xFFEEF0F3);
  static const Color surfaceDark = Color(0xFF0A0B0D);
  static const Color surfaceDarkElevated = Color(0xFF16181C);

  // ── Hairlines ──────────────────────────────────────────────────────────────
  static const Color hairline = Color(0xFFDEE1E6);
  static const Color hairlineSoft = Color(0xFFEEF0F3);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF0A0B0D);
  static const Color body = Color(0xFF5B616E);
  static const Color muted = Color(0xFF7C828A);
  static const Color mutedSoft = Color(0xFFA8ACB3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFA8ACB3);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color up = Color(0xFF05B169);
  static const Color down = Color(0xFFCF202F);

  // ── Border Radius ──────────────────────────────────────────────────────────
  static const double rxXs = 4;
  static const double rxSm = 8;
  static const double rxMd = 12;
  static const double rxLg = 16;
  static const double rxXl = 24;
  static const double rxPill = 100;

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double spXxs = 4;
  static const double spXs = 8;
  static const double spSm = 12;
  static const double spBase = 16;
  static const double spMd = 20;
  static const double spLg = 24;
  static const double spXl = 32;
  static const double spXxl = 48;
  static const double spSection = 96;

  // ── Nav height ─────────────────────────────────────────────────────────────
  static const double navHeight = 64;
  static const double tabHeight = 48;

  // ── Content max width ──────────────────────────────────────────────────────
  static const double maxWidth = 1200;
}

abstract final class DT {
  static const String _sans = 'Pretendard';

  // display — weight 400, negative tracking
  static const TextStyle displayMega = TextStyle(
    fontFamily: _sans,
    fontSize: 72,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: -2,
  );
  static const TextStyle displayXl = TextStyle(
    fontFamily: _sans,
    fontSize: 56,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: -1.5,
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: _sans,
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 1.05,
    letterSpacing: -1.2,
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: _sans,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: -0.8,
  );
  static const TextStyle displaySm = TextStyle(
    fontFamily: _sans,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: -0.5,
  );

  // title
  static const TextStyle titleLg = TextStyle(
    fontFamily: _sans,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.4,
  );
  static const TextStyle titleMd = TextStyle(
    fontFamily: _sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );
  static const TextStyle titleSm = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // body
  static const TextStyle bodyMd = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle captionStrong = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.3,
  );

  // interactive
  static const TextStyle button = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );
  static const TextStyle buttonSm = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );
  static const TextStyle navLink = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // number (mono)
  static const TextStyle numberDisplay = TextStyle(
    fontFamily: _sans,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}

// ── Reusable button styles ──────────────────────────────────────────────────

ButtonStyle dPrimaryButtonStyle({double height = 44}) => ElevatedButton.styleFrom(
  backgroundColor: DC.primary,
  foregroundColor: DC.onPrimary,
  textStyle: DT.button,
  shape: const StadiumBorder(),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  minimumSize: Size(0, height),
  elevation: 0,
);

ButtonStyle dPrimaryButtonStyleLg() => ElevatedButton.styleFrom(
  backgroundColor: DC.primary,
  foregroundColor: DC.onPrimary,
  textStyle: DT.button,
  shape: const StadiumBorder(),
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  minimumSize: const Size(0, 56),
  elevation: 0,
);

ButtonStyle dSecondaryButtonStyle({double height = 44}) => ElevatedButton.styleFrom(
  backgroundColor: DC.surfaceStrong,
  foregroundColor: DC.ink,
  textStyle: DT.button,
  shape: const StadiumBorder(),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  minimumSize: Size(0, height),
  elevation: 0,
);

ButtonStyle dOutlineOnDarkButtonStyle({double height = 44}) => OutlinedButton.styleFrom(
  foregroundColor: DC.onDark,
  textStyle: DT.button,
  shape: const StadiumBorder(),
  side: const BorderSide(color: DC.onDark),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
  minimumSize: Size(0, height),
);

ButtonStyle dOutlineOnDarkButtonStyleLg() => OutlinedButton.styleFrom(
  foregroundColor: DC.onDark,
  textStyle: DT.button,
  shape: const StadiumBorder(),
  side: const BorderSide(color: DC.onDark, width: 1.5),
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  minimumSize: const Size(0, 56),
);

ButtonStyle dGhostButtonStyle() => TextButton.styleFrom(
  foregroundColor: DC.primary,
  textStyle: DT.button,
  padding: const EdgeInsets.symmetric(horizontal: 4),
);
