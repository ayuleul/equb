import 'package:flutter/material.dart';

import '../../../shared/kit/kit.dart';

class SimpleSettingsInfoScreen extends StatelessWidget {
  const SimpleSettingsInfoScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return KitScaffold(
      appBar: KitAppBar(title: title, showAvatar: false),
      child: ListView(
        children: [
          KitCard(
            child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
