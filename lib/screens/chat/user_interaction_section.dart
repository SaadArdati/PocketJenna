import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../managers/gpt_manager.dart';
import '../../models/message_status.dart';
import '../../ui/coming_soon.dart';
import '../../ui/theme_extensions.dart';

class UserInteractionInput extends StatefulWidget {
  final Color? primaryColor;
  final Color? onPrimaryColor;

  const UserInteractionInput({
    super.key,
    this.primaryColor,
    this.onPrimaryColor,
  });

  @override
  State<UserInteractionInput> createState() => _UserInteractionInputState();
}

class _UserInteractionInputState extends State<UserInteractionInput> {
  late final focusNode = FocusNode(
    onKey: (FocusNode node, RawKeyEvent evt) {
      if (!evt.isShiftPressed && evt.logicalKey == LogicalKeyboardKey.enter) {
        if (evt is RawKeyDownEvent) {
          triggerSend(node.context!, generateResponse: true);
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  final TextEditingController textController = TextEditingController();

  void triggerSend(BuildContext context, {required bool generateResponse}) {
    if (textController.text.isEmpty) {
      showComingSoonDialog(context, 'Audio message');
    }
    // if (!Form.of(context).validate()) return;
    if (textController.text.trim().isEmpty) return;

    final GPTManager gpt = context.read<GPTManager>();
    gpt.sendMessage(textController.text, generateResponse: generateResponse);
    textController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.watch<GPTManager>();
    final BorderRadius borderRadius = BorderRadius.circular(12);

    final bool isGenerating = gpt.chat != null &&
        gpt.messages.isNotEmpty &&
        gpt.messages.last.status == MessageStatus.streaming;
    return Form(
      child: Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: widget.primaryColor ?? context.colorScheme.primary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800, minHeight: 56),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Add attachment',
                    onPressed: () {
                      showComingSoonDialog(context, 'Add attachment');
                    },
                    icon: Icon(
                      Icons.add,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 3,
                      ),
                      child: TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        maxLength: 10000,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        autovalidateMode: AutovalidateMode.disabled,
                        onChanged: (_) {
                          setState(() {});
                        },
                        onFieldSubmitted: isGenerating
                            ? null
                            : (_) => triggerSend(
                                  context,
                                  generateResponse: true,
                                ),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'Type a message...',
                          labelStyle: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                          isDense: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          filled: true,
                          fillColor: widget.onPrimaryColor ??
                              context.colorScheme.primaryContainer,
                          hoverColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: const BorderSide(width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: context.colorScheme.onPrimaryContainer,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        cursorColor: context.colorScheme.onPrimaryContainer,
                        cursorRadius: const Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: Tooltip(
                        message: textController.text.isEmpty
                            ? 'Start recording'
                            : 'Send message',
                        child: InkWell(
                          onTap: isGenerating
                              ? null
                              : () => triggerSend(
                                    context,
                                    generateResponse: true,
                                  ),
                          onLongPress: isGenerating
                              ? null
                              : () {
                                  triggerSend(
                                    context,
                                    generateResponse: false,
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              textController.text.isEmpty
                                  ? Icons.mic
                                  : Icons.send,
                              color: context.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
