import 'dart:math';

import 'package:flutter/material.dart';

import '../models/prompt.dart';
import 'bounce_button.dart';
import 'theme_extensions.dart';

class GPTCard extends StatelessWidget {
  final Prompt prompt;
  final bool isComingSoon;
  final VoidCallback onTap;

  const GPTCard({
    super.key,
    required this.prompt,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(
      top: Radius.circular(18),
      bottom: Radius.circular(80),
    );
    return Center(
      child: BounceWrapper(
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 200,
            minWidth: 175,
            maxWidth: 175,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: context.colorScheme.surface.withOpacity(0.9),
            border: Border.all(
              color: context.colorScheme.primary,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  // splashColor: context.colorScheme.secondary,
                  // highlightColor: context.colorScheme.secondaryContainer,
                  onTap: isComingSoon ? null : onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary,
                        ),
                        child: Text(
                          prompt.title,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: context.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            prompt.description ?? prompt.prompts.first,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                            style: context.textTheme.bodySmall!.copyWith(
                                color: context.colorScheme.onSurface,
                                fontSize: 10),
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 56,
                      //   width: double.infinity,
                      //   child: AssetManager.getPromptIcon(
                      //     prompt.icon,
                      //     color: context.colorScheme.onSurface,
                      //     size: 24,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              if (isComingSoon)
                Center(
                  child: Transform.rotate(
                    angle: -35 * pi / 180,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: context.colorScheme.inverseSurface,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Coming Soon',
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: context.colorScheme.onInverseSurface,
                          ),
                        )),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
