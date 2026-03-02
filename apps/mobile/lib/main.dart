import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrapConfig = await AppBootstrapConfig.load();

  runApp(
    ProviderScope(
      overrides: [appBootstrapConfigProvider.overrideWithValue(bootstrapConfig)],
      child: const EqubApp(),
    ),
  );
}
