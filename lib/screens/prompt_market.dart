import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../managers/data/data_manager.dart';
import '../models/prompt.dart';
import '../ui/bounce_button.dart';
import '../ui/custom_scaffold.dart';
import '../ui/firestore_query_builder.dart';
import '../ui/theme_extensions.dart';

class PromptMarket extends StatefulWidget {
  const PromptMarket({super.key});

  @override
  State<PromptMarket> createState() => _PromptMarketState();
}

class _PromptMarketState extends State<PromptMarket> {
  int pageSize = 20;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      // backgroundColor: context.colorScheme.surface,
      title: Text(
        'Prompt Market',
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
          context.go('/home', extra: {'from': '/prompt-market'});
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FirestoreQueryBuilder<Prompt>(
            query: (int limit) => DataManager.instance.fetchMarket(0, limit),
            builder: (
              context,
              FirestoreQueryBuilderSnapshot<Prompt> item,
              Widget? child,
            ) {
              return ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: item.docs.length,
                clipBehavior: Clip.none,
                // separatorBuilder: (BuildContext context, int index) =>
                //     ColoredBox(
                //         color: context.colorScheme.background,
                //         child: Container(
                //           height: 2,
                //           margin: const EdgeInsets.symmetric(horizontal: 16),
                //           decoration: BoxDecoration(
                //             color: context.colorScheme.primary,
                //           ),
                //         )),
                itemBuilder: (BuildContext context, int index) {
                  final prompt = item.docs[index];
                  return GPTPromptTile(
                    prompt: prompt,
                    onTap: () => context.go(
                      '/chat?promptID=${prompt.id}',
                      extra: {'from': '/prompt-market'},
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
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
