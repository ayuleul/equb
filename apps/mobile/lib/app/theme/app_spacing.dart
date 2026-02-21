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

  static const double input = 12;
  static const double card = 16;
  static const double sm = 10;
  static const double md = input;
  static const double lg = card;
  static const double pill = 999;

  static const BorderRadius smRounded = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius inputRounded = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius cardRounded = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius mdRounded = inputRounded;
  static const BorderRadius lgRounded = cardRounded;
  static const BorderRadius pillRounded = BorderRadius.all(
    Radius.circular(pill),
  );
}
