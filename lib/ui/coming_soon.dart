import 'package:flutter/material.dart';

import 'theme_extensions.dart';

void showComingSoonDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This feature is coming soon!',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
