import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../managers/prompt_testing_manager.dart';
import '../../ui/bounce_button.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/theme_extensions.dart';
import '../settings_screen.dart';

class PromptCreationBody extends StatefulWidget {
  const PromptCreationBody({super.key});

  @override
  State<PromptCreationBody> createState() => _PromptCreationBodyState();
}

class _PromptCreationBodyState extends State<PromptCreationBody> {
  final TextEditingController promptController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final PromptTestingManager promptTestingManager =
        context.read<PromptTestingManager>();

    promptController.text = promptTestingManager.prompt ?? '';
  }

  @override
  void dispose() {
    promptController.dispose();
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
          context.go('/home', extra: {'from': '/prompt-market'});
        },
      ),
      actions: [
        ScaffoldAction(
          onTap: () {
            AdaptiveTheme.of(context).toggleThemeMode();
          },
          icon: Icons.dark_mode,
          tooltip: 'Toggle theme',
        )
      ],
      title: Text(
        'Prompt Creator',
        textAlign: TextAlign.center,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      body: Form(
        child: Builder(builder: (context) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: BounceWrapper(
                      onTap: () {},
                      child: JennaTile(
                        padding: const EdgeInsets.all(8),
                        surfaceColor: context.colorScheme.secondaryContainer,
                        borderColor: context.colorScheme.secondary,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: context.colorScheme.onSecondaryContainer,
                            )
                                .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .moveY(
                                  delay: 1000.ms,
                                  duration: 250.ms,
                                  curve: Curves.fastOutSlowIn,
                                  begin: 0,
                                  end: -6,
                                ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Learn how to write good and effective prompts that work',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: promptController,
                        maxLength: 5000,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Please enter a prompt.';
                          }
                          if (text.length < 20) {
                            return 'Prompt is too short.';
                          }
                          return null;
                        },
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText:
                              'Your prompt must be as detailed and verbose as possible. Provide example inputs with example outputs.',
                          hintMaxLines: 10,
                          filled: true,
                          isDense: true,
                          fillColor: context.colorScheme.surface,
                          contentPadding: const EdgeInsets.all(16),
                          hoverColor: Colors.transparent,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: context.colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: context.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        cursorColor: context.colorScheme.onPrimaryContainer,
                        cursorRadius: const Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FilledBounceButton(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        onPressed: () {
                          if (Form.of(context).validate()) {
                            final PromptTestingManager promptTestingManager =
                                context.read<PromptTestingManager>();
                            promptTestingManager.prompt = promptController.text;
                            context.go('/prompt-creator/test', extra: {
                              'from': '/prompt-creator',
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
