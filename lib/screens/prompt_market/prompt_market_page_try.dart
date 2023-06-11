import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../managers/data/data_manager.dart';
import '../../managers/gpt_manager.dart';
import '../../managers/prompt_testing_manager.dart';
import '../../models/chat.dart';
import '../../models/prompt.dart';
import '../../models/user_model.dart';
import '../../ui/bounce_button.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/theme_extensions.dart';
import '../chat/chat_section.dart';
import '../settings_screen.dart';

class PromptMarketPageTrialWrapper extends StatelessWidget {
  final Prompt prompt;

  const PromptMarketPageTrialWrapper({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GPTManager>(
      create: (context) => GPTManager(isTestMode: true),
      child: PromptMarketPageTrial(prompt: prompt),
    );
  }
}

class PromptMarketPageTrial extends StatefulWidget {
  final Prompt prompt;

  const PromptMarketPageTrial({super.key, required this.prompt});

  @override
  State<PromptMarketPageTrial> createState() => _PromptMarketPageTrialState();
}

class _PromptMarketPageTrialState extends State<PromptMarketPageTrial> {
  final ScrollController scrollController = ScrollController();

  late final Stream<Chat?> chatStream;

  bool loading = false;
  String? error;

  StreamSubscription<UserModel?>? userStreamListener;

  @override
  void initState() {
    super.initState();

    final GPTManager gpt = context.read<GPTManager>();
    gpt.loadHistory();

    chatStream = gpt.chatStream;

    gpt.openChat(
      notify: false,
      prompt: widget.prompt,
    );

    gpt.addListener(gptListener);

    userStreamListener = DataManager.instance.userStream.listen(userListener);
  }

  @override
  void dispose() {
    userStreamListener?.cancel();
    scrollController.dispose();

    super.dispose();
  }

  void userListener(UserModel? user) {
    setState(() {});
  }

  void gptListener() {
    final PromptTestingManager promptTestingManager =
        context.read<PromptTestingManager>();
    final GPTManager gpt = context.read<GPTManager>();
    final Chat? chat = gpt.chat;
    if (chat != null) {
      promptTestingManager.testChat = chat;
    }
  }

  Future<void> save() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await DataManager.instance.savePrompt(promptID: widget.prompt.id);
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
      await DataManager.instance.unSavePrompt(promptID: widget.prompt.id);
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
    return CustomScaffold(
      headerColor: context.colorScheme.secondary,
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onTap: () {
          context.go('/prompt-market/${widget.prompt.id}',
              extra: {'from': '/prompt-market/${widget.prompt.id}/try'});
        },
      ),
      title: Text(
        widget.prompt.title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatSection(
              primaryColor: context.colorScheme.secondary,
              onPrimaryColor: context.colorScheme.secondaryContainer,
              scrollController: scrollController,
              chatOverlays: [
                buildActionContainer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionContainer(BuildContext context) {
    final bool isSaved = DataManager.instance.currentUser?.pinnedPrompts
            .contains(widget.prompt.id) ??
        false;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: JennaTile(
          padding: const EdgeInsets.all(8),
          surfaceColor: context.colorScheme.secondaryContainer,
          borderColor: context.colorScheme.secondary,
          title: 'PROMPT TESTER',
          icon: const Icon(Icons.construction),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const InformationText(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextBounceButton(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    primaryColor: context.colorScheme.onSecondaryContainer,
                    onPrimaryColor: context.colorScheme.onSecondaryContainer,
                    onPressed: () {
                      context.go('/prompt-market/${widget.prompt.id}');
                    },
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: isSaved
                        ? FilledBounceButton(
                            primaryColor: context.colorScheme.secondary,
                            onPrimaryColor: context.colorScheme.onSecondary,
                            onPressed: loading ? null : unSave,
                            icon: loading
                                ? const CupertinoActivityIndicator()
                                : const Icon(
                                    Icons.favorite,
                                  ),
                            label: const Text('Unsave'),
                          )
                        : OutlinedBounceButton(
                            primaryColor: context.colorScheme.secondary,
                            onPrimaryColor: context.colorScheme.onSecondary,
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
            ],
          ),
        ),
      ),
    );
  }
}

class InformationText extends StatefulWidget {
  const InformationText({super.key});

  @override
  State<InformationText> createState() => _InformationTextState();
}

class _InformationTextState extends State<InformationText> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBounceButton(
          onPressed: () {
            setState(() {
              expanded = !expanded;
            });
          },
          icon: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: context.colorScheme.onSecondaryContainer,
          ),
          // scaleStrength: 0.25,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutQuart,
            alignment: Alignment.centerLeft,
            child: Text(
              'Test this prompt with the chat below.\nThis conversation will not be saved to your account.',
              maxLines: expanded ? 10 : 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
