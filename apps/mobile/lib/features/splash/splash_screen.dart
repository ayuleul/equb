import 'package:flutter/material.dart';

import '../../shared/widgets/loading_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: LoadingView(message: 'Checking session...')),
    );
  }
}
