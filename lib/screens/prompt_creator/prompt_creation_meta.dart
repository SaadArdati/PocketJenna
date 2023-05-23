import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../managers/prompt_testing_manager.dart';
import '../../ui/bounce_button.dart';
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

  bool isUploading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    final PromptTestingManager promptTestingManager =
        context.read<PromptTestingManager>();
    titleController.text = promptTestingManager.title ?? '';
    descriptionController.text = promptTestingManager.description ?? '';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> upload() async {
    setState(() {
      isUploading = true;
      error = null;
    });

    final PromptTestingManager promptTestingManager =
        context.read<PromptTestingManager>();

    try {
      await promptTestingManager.upload();

      if (mounted) {
        context.go('/prompt-creator/complete');
      }
    } catch (e, str) {
      error = e.toString();
      debugPrintStack(stackTrace: str, label: '$e');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PromptTestingManager promptTestingManager =
        context.read<PromptTestingManager>();

    final BorderRadius borderRadius = BorderRadius.circular(12);
    return CustomScaffold(
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onTap: isUploading
            ? null
            : () {
                context.go(
                  '/prompt-creator/test',
                  extra: {'from': '/prompt-creator/meta'},
                );
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
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: JennaTile(
                        padding: const EdgeInsets.all(8),
                        surfaceColor: context.colorScheme.surface,
                        borderColor: context.colorScheme.secondary,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: context.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Keep your title short and sweet so that it's easily recognizable. One or two words is ideal. You can always add more details in the description.",
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
                        enabled: !isUploading,
                        controller: titleController,
                        maxLength: 50,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Please enter a title.';
                          }
                          if (text.length < 4) {
                            return 'Title is too short.';
                          }
                          return null;
                        },
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Prompt Title',
                          labelStyle: context.textTheme.bodyMedium?.copyWith(
                            color:
                                context.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          floatingLabelStyle:
                              context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: context.colorScheme.surface,
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
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        enabled: !isUploading,
                        controller: descriptionController,
                        maxLength: 200,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        textAlignVertical: TextAlignVertical.top,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: 'Prompt Description (optional)',
                          labelStyle: context.textTheme.bodyMedium?.copyWith(
                            color:
                                context.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          alignLabelWithHint: true,
                          floatingLabelStyle:
                              context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: context.colorScheme.surface,
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
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilledBounceButton(
                          icon: isUploading
                              ? const CupertinoActivityIndicator()
                              : const Icon(Icons.arrow_forward),
                          label: Text(isUploading ? 'Uploading...' : 'Next'),
                          onPressed: isUploading
                              ? null
                              : () {
                                  if (Form.of(context).validate()) {
                                    promptTestingManager.description =
                                        descriptionController.text;
                                    promptTestingManager.title =
                                        titleController.text;

                                    context.go(
                                      '/prompt-creator/preview',
                                      extra: {'from': '/prompt-creator/meta'},
                                    );
                                  }
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
