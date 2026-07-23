import 'package:flutter/material.dart';

import '../d_tokens.dart';

TextStyle _modeStyle({
  required double size,
  required FontWeight weight,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: DT.fontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// Base Pretendard text primitive. Mirrors the shape most view code already
/// passes inline (`TextStyle(fontFamily: 'Pretendard', fontSize: ..., color:
/// ...)`), so migrating a call site is a mechanical, visually-lossless swap
/// rather than a restyle. Prefer [ModeMediumText]/[ModeSemiBoldText]/
/// [ModeBoldText] over passing `weight:` directly when the weight is fixed.
class ModeText extends StatelessWidget {
  const ModeText(
    this.data, {
    super.key,
    required this.size,
    this.weight = FontWeight.w400,
    this.color,
    this.height,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  final String data;
  final double size;
  final FontWeight weight;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _modeStyle(
        size: size,
        weight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}

/// [ModeText] fixed at [FontWeight.w500].
class ModeMediumText extends StatelessWidget {
  const ModeMediumText(
    this.data, {
    super.key,
    required this.size,
    this.color,
    this.height,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  final String data;
  final double size;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _modeStyle(
        size: size,
        weight: FontWeight.w500,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}

/// [ModeText] fixed at [FontWeight.w600].
class ModeSemiBoldText extends StatelessWidget {
  const ModeSemiBoldText(
    this.data, {
    super.key,
    required this.size,
    this.color,
    this.height,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  final String data;
  final double size;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _modeStyle(
        size: size,
        weight: FontWeight.w600,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}

/// [ModeText] fixed at [FontWeight.w700].
class ModeBoldText extends StatelessWidget {
  const ModeBoldText(
    this.data, {
    super.key,
    required this.size,
    this.color,
    this.height,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  final String data;
  final double size;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _modeStyle(
        size: size,
        weight: FontWeight.w700,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}
