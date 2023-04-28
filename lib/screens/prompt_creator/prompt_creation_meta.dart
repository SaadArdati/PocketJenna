import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../ui/custom_scaffold.dart';
import '../../ui/theme_extensions.dart';
import '../settings_screen.dart';

class PromptCreationMeta extends StatefulWidget {
  const PromptCreationMeta({super.key});

  @override
  State<PromptCreationMeta> createState() => _PromptCreationMetaState();
}

class _PromptCreationMetaState extends State<PromptCreationMeta> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void triggerSend(String text) {}

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    return CustomScaffold(
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onTap: () {
          context.go(
            '/prompt-creator',
            extra: {'from': '/prompt-creator/meta'},
          );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Keep your prompt title short and sweet. It's the first thing people will see when they're browsing for prompts on the prompt market.",
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: titleController,
                maxLength: 50,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                maxLines: 1,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  labelText: 'Prompt Title',
                  labelStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  floatingLabelStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondaryContainer,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: context.colorScheme.surface,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: descriptionController,
                maxLength: 200,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                maxLines: 3,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  labelText: 'Prompt Description',
                  labelStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  floatingLabelStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondaryContainer,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: context.colorScheme.surface,
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
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  onPressed: () {
                    context.go('/prompt-creator/body');
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
