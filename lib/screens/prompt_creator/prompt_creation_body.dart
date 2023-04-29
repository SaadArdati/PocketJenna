import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../ui/custom_scaffold.dart';
import '../../ui/jenna_button.dart';
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
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: JennaButton(
                  onTap: () {},
                  child: JennaTile(
                    padding: const EdgeInsets.all(8),
                    surfaceColor: context.colorScheme.primaryContainer,
                    borderColor: context.colorScheme.primary,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: context.colorScheme.primary,
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
                      if (text.length < 50) {
                        return 'Prompt must be at least 100 characters long.';
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
                          color: context.colorScheme.secondaryContainer,
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
                  child: FilledButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    onPressed: () {
                      if (Form.of(context).validate()) {
                        context.go('/prompt-creator/tester', extra: {
                          'prompt': promptController.text,
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        }),
      ),
    );
  }
}
