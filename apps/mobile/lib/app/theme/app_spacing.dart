import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double pill = 999;

  static const BorderRadius smRounded = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRounded = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRounded = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillRounded = BorderRadius.all(
    Radius.circular(pill),
  );
}
