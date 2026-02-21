import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class KitDialog {
  const KitDialog._();

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor: Theme.of(
                      dialogContext,
                    ).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  static Future<int?> threeActions({
    required BuildContext context,
    required String title,
    required String message,
    required String firstLabel,
    required String secondLabel,
    required String thirdLabel,
  }) {
    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(0),
            child: Text(firstLabel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(1),
            child: Text(secondLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(2),
            child: Text(thirdLabel),
          ),
        ],
      ),
    );
  }
}

Future<String?> promptText({
  required BuildContext context,
  required String title,
  required String label,
  required String hint,
  String submitLabel = 'Submit',
}) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isEmpty) {
              return;
            }
            Navigator.of(dialogContext).pop(value);
          },
          child: Text(submitLabel),
        ),
      ],
    ),
  );
}

class KitDialogContentSection extends StatelessWidget {
  const KitDialogContentSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      spacedChildren.add(children[index]);
      if (index < children.length - 1) {
        spacedChildren.add(const SizedBox(height: AppSpacing.md));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: spacedChildren);
  }
}
