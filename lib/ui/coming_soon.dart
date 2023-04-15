import 'package:flutter/material.dart';

import 'theme_extensions.dart';

void showComingSoonDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Dismiss',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onBackground,
              ),
            ),
          ),
        ],
      );
    },
  );
}
