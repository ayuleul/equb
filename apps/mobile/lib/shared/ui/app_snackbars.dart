import 'package:flutter/material.dart';

import '../kit/kit.dart';

class AppSnackbars {
  const AppSnackbars._();

  static void success(BuildContext context, String message) {
    KitToast.success(context, message);
  }

  static void error(BuildContext context, String message) {
    KitToast.error(context, message);
  }

  static void info(BuildContext context, String message) {
    KitToast.info(context, message);
  }
}
