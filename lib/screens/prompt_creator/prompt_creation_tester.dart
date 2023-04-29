import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../managers/auth/auth_manager.dart';
import '../../managers/gpt_manager.dart';
import '../../models/chat.dart';
import '../../models/prompt.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/jenna_button.dart';
import '../../ui/theme_extensions.dart';
import '../chat/chat_section.dart';
import '../settings_screen.dart';

class PromptCreationTesterWrapper extends StatelessWidget {
  final String? prompt;

  const PromptCreationTesterWrapper({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GPTManager>(
      create: (context) => GPTManager(isTestMode: false),
      child: PromptCreationTester(prompt: prompt),
    );
  }
}

class PromptCreationTester extends StatefulWidget {
  final String? prompt;

  const PromptCreationTester({super.key, required this.prompt});

  @override
  State<PromptCreationTester> createState() => _PromptCreationTesterState();
}

class _PromptCreationTesterState extends State<PromptCreationTester> {
  final ScrollController scrollController = ScrollController();

  late final Stream<Chat?> chatStream;

  @override
  void initState() {
    super.initState();

    if (widget.prompt == null) return;

    final GPTManager gpt = context.read<GPTManager>();
    gpt.loadHistory();

    chatStream = gpt.chatStream;

    gpt.openChat(
      notify: false,
      chatID: null,
      prompt: Prompt.simple(
        title: 'Prompt Creator',
        prompts: [widget.prompt!],
        icon: '${Icons.construction.codePoint}',
        userID: AuthManager.instance.currentAuth!.id,
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    return CustomScaffold(
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onTap: () {
          context
              .go('/prompt-creator', extra: {'from': '/prompt-creator/tester'});
        },
      ),
      title: Text(
        'Prompt Creator',
        textAlign: TextAlign.center,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      body: widget.prompt == null
          ? Center(
              child: Text(
                'No prompt provided',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onPrimary,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ChatSection(
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
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: JennaTile(
          padding: const EdgeInsets.all(8),
          surfaceColor: context.colorScheme.primaryContainer,
          borderColor: context.colorScheme.primary,
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
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    onPressed: () {
                      context.go('/prompt-creator');
                    },
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Continue'),
                      onPressed: () {
                        context.go('/prompt-creator/meta');
                      },
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
        JennaButton(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutQuart,
            alignment: Alignment.centerLeft,
            child: Text(
              'Test your prompt with the chat below.\nYou can keep modifying your prompt and come back here until you are satisfied.\nOnce you are, tap on "continue" to proceed to the next step.',
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
