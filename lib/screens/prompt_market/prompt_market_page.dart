import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../managers/data/data_manager.dart';
import '../../models/prompt.dart';
import '../../ui/bounce_button.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/theme_extensions.dart';
import '../settings_screen.dart';

class PromptMarketPage extends StatefulWidget {
  final String promptID;

  const PromptMarketPage({super.key, required this.promptID});

  @override
  State<PromptMarketPage> createState() => _PromptMarketPageState();
}

class _PromptMarketPageState extends State<PromptMarketPage> {
  late final Future<Prompt> fetchPromptFuture =
      DataManager.instance.fetchPrompt(
    promptID: widget.promptID,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Prompt>(
      future: fetchPromptFuture,
      builder: (context, snapshot) {
        final Prompt? prompt = snapshot.data;
        return CustomScaffold(
          title: Text(
            prompt?.title ?? 'Loading Prompt',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            ScaffoldAction(
              onTap: () {
                AdaptiveTheme.of(context).toggleThemeMode();
              },
              icon: Icons.dark_mode,
              tooltip: 'Toggle theme',
            )
          ],
          leading: ScaffoldAction(
            tooltip: 'Prompt Market',
            icon: Icons.arrow_back,
            onTap: () {
              context.go(
                '/prompt-market',
                extra: {'from': '/prompt-market/${widget.promptID}'},
              );
            },
          ),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 800),
              child: prompt == null
                  ? const CupertinoActivityIndicator()
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: FilledBounceButton(
                                onPressed: () {
                                  context.go(
                                    '/prompt-market/${prompt.id}/try',
                                    extra: prompt,
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Try out'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledBounceButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (prompt.description != null) ...[
                          JennaTile(
                            title: 'Description',
                            padding: const EdgeInsets.all(8),
                            child: Text(prompt.description!),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ...prompt.prompts.mapIndexed(
                          (index, text) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: JennaTile(
                              title: prompt.prompts.length == 1
                                  ? 'Prompt'
                                  : 'Prompt ${index + 1}',
                              padding: const EdgeInsets.all(8),
                              child: SelectionArea(
                                child: Text(text),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        JennaTile(
                          title: 'Details',
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Author: ${prompt.userID}'),
                              Text(
                                'Created On: ${prompt.createdOn.toLocal().toString().split(' ').first}',
                              ),
                              Text(
                                'Last Updated: ${prompt.updatedOn.toLocal().toString().split(' ').first}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class GPTPromptTile extends StatefulWidget {
  final Prompt prompt;
  final VoidCallback onTap;

  const GPTPromptTile({super.key, required this.prompt, required this.onTap});

  @override
  State<GPTPromptTile> createState() => _GPTPromptTileState();
}

class _GPTPromptTileState extends State<GPTPromptTile> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: BounceWrapper(
          direction: AxisDirection.right,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colorScheme.primary,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.prompt.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.prompt.description == null)
                        upvoteButton(context),
                    ],
                  ),
                  if (widget.prompt.description != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.prompt.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        upvoteButton(context),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget upvoteButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: context.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_upward,
            color: context.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.prompt.upvotes.length}',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
