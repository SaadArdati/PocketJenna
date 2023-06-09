import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../managers/data/data_manager.dart';
import '../../models/prompt.dart';
import '../../models/user_model.dart';
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
  bool loading = false;
  String? error;

  late final Future<Prompt> fetchPromptFuture =
      DataManager.instance.fetchPrompt(
    promptID: widget.promptID,
  );

  StreamSubscription<UserModel?>? userStreamListener;

  @override
  void initState() {
    super.initState();

    userStreamListener = DataManager.instance.userStream.listen(userListener);
  }

  @override
  void dispose() {
    userStreamListener?.cancel();
    super.dispose();
  }

  void userListener(UserModel? user) {
    setState(() {});
  }

  Future<void> save() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await DataManager.instance.savePrompt(promptID: widget.promptID);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> unSave() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await DataManager.instance.unSavePrompt(promptID: widget.promptID);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaved = DataManager.instance.currentUser?.pinnedPrompts
            .contains(widget.promptID) ??
        false;

    return FutureBuilder<Prompt>(
      future: fetchPromptFuture,
      builder: (context, snapshot) {
        final Prompt? prompt = snapshot.data;
        return CustomScaffold(
          title: Text(
            prompt?.title ?? 'Loading Prompt',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
          body: SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 800),
              child: prompt == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: FilledBounceButton(
                                onPressed: loading
                                    ? null
                                    : () {
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
                              child: isSaved
                                  ? FilledBounceButton(
                                      onPressed: loading ? null : unSave,
                                      icon: loading
                                          ? const CupertinoActivityIndicator()
                                          : const Icon(
                                              Icons.favorite,
                                            ),
                                      label: const Text('Unsave'),
                                    )
                                  : OutlinedBounceButton(
                                      onPressed: loading ? null : save,
                                      icon: loading
                                          ? const CupertinoActivityIndicator()
                                          : const Icon(
                                              Icons.favorite_border,
                                            ),
                                      label: const Text('Save'),
                                    ),
                            ),
                          ],
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutQuart,
                          heightFactor: error == null ? 0 : 1,
                          alignment: Alignment.topCenter,
                          child: error == null
                              ? const SizedBox.shrink()
                              : Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.error,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          error!,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                child: Text(
                                  text,
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DefaultTextStyle(
                          style: context.textTheme.bodySmall!,
                          child: JennaTile(
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
