import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../managers/auth/auth_manager.dart';
import '../../managers/prompt_testing_manager.dart';
import '../../models/prompt.dart';
import '../../ui/bounce_button.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/gpt_card.dart';
import '../../ui/theme_extensions.dart';
import '../settings_screen.dart';

class PromptCreationPreview extends StatefulWidget {
  const PromptCreationPreview({super.key});

  @override
  State<PromptCreationPreview> createState() => _PromptCreationPreviewState();
}

class _PromptCreationPreviewState extends State<PromptCreationPreview> {
  bool isUploading = false;
  String? error;

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
        context.go('/home');
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                GPTCard(
                  prompt: Prompt.simple(
                    title: promptTestingManager.title!,
                    prompts: [promptTestingManager.prompt!],
                    icon: 'https://picsum.photos/256',
                    userID: AuthManager.instance.currentAuth!.id,
                    isPublic: promptTestingManager.isPublic,
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BounceWrapper(
                    onTap: () {
                      promptTestingManager.isPublic =
                          !promptTestingManager.isPublic;
                      setState(() {});
                    },
                    child: JennaTile(
                      child: Material(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: !isUploading,
                          child: CheckboxListTile(
                            value: promptTestingManager.isPublic,
                            onChanged: (bool? value) {
                              promptTestingManager.isPublic = value ?? false;
                              setState(() {});
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            selectedTileColor:
                                context.colorScheme.primaryContainer,
                            selected: promptTestingManager.isPublic,
                            title: Text(
                              'Publish this prompt on the prompt market.',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FilledBounceButton(
                      icon: isUploading
                          ? CupertinoActivityIndicator(
                              color: context.colorScheme.onPrimary,
                            )
                          : Icon(
                              Icons.check,
                              color: context.colorScheme.onPrimary,
                            ),
                      label: Text(isUploading ? 'Uploading...' : 'Finish'),
                      onPressed: isUploading
                          ? null
                          : () {
                              upload();
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
