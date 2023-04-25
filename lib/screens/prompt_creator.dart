import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../ui/custom_scaffold.dart';
import '../ui/theme_extensions.dart';

class PromptCreator extends StatefulWidget {
  const PromptCreator({super.key});

  @override
  State<PromptCreator> createState() => _PromptCreatorState();
}

class _PromptCreatorState extends State<PromptCreator> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController promptController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    promptController.dispose();
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
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: titleController,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              maxLines: 1,
              autovalidateMode: AutovalidateMode.disabled,
              onChanged: (_) {
                setState(() {});
              },
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
              decoration: InputDecoration(
                counterText: '',
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
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              maxLines: 1,
              autovalidateMode: AutovalidateMode.disabled,
              onChanged: (_) {
                setState(() {});
              },
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
              decoration: InputDecoration(
                counterText: '',
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
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
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                autovalidateMode: AutovalidateMode.disabled,
                onChanged: (_) {
                  setState(() {});
                },
                onFieldSubmitted: (String value) => triggerSend(value),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  hintText: 'Only talk in haikus',
                  isDense: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
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
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              icon: Icon(Icons.preview),
              label: Text('Test Prompt'),
              onPressed: () {},
              // child: Text(
              //   'Preview',
              //   style: context.textTheme.bodyMedium?.copyWith(
              //     color: context.colorScheme.onPrimary,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
