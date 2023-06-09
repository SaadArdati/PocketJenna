import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../managers/gpt_manager.dart';
import '../../models/chat.dart';
import '../../models/chat_message.dart';
import '../../models/message_status.dart';
import '../../ui/theme_extensions.dart';
import 'chat_bubbles.dart';
import 'user_interaction_section.dart';

class ChatSection extends StatefulWidget {
  final ScrollController scrollController;
  final List<Widget>? chatOverlays;
  final Color? primaryColor;
  final Color? onPrimaryColor;

  const ChatSection({
    super.key,
    required this.scrollController,
    this.chatOverlays,
    this.primaryColor,
    this.onPrimaryColor,
  });

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.watch<GPTManager>();
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: StreamBuilder<Chat?>(
                        stream: gpt.chatStream,
                        initialData: gpt.chat,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                snapshot.error.toString(),
                                style: context.textTheme.bodyMedium,
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }

                          final bool isGenerating =
                              snapshot.data!.messages.isNotEmpty &&
                                  gpt.messages.last.status ==
                                      MessageStatus.streaming;

                          final fullChat = snapshot.data!.toFullChat;
                          return SelectionArea(
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              controller: widget.scrollController,
                              reverse: true,
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: isGenerating ? 32 : 0,
                              ),
                              itemCount: fullChat.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final int reversedIndex =
                                    fullChat.length - 1 - index;
                                final ChatMessage message =
                                    fullChat[reversedIndex];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: index == fullChat.length - 1
                                        ? (Scaffold.of(context)
                                                    .appBarMaxHeight ??
                                                48) +
                                            16
                                        : 0,
                                    bottom: index == 0 ? 16 : 0,
                                  ),
                                  child: ChatMessageBubble(
                                    message: message,
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: StopGeneratingButton(),
                  ),
                ],
              ),
            ),
            UserInteractionInput(
              primaryColor: widget.primaryColor,
              onPrimaryColor: widget.onPrimaryColor,
            ),
          ],
        ),
        ...?widget.chatOverlays,
      ],
    );
  }
}

class StopGeneratingButton extends StatelessWidget {
  const StopGeneratingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.watch<GPTManager>();
    return StreamBuilder<Chat?>(
      stream: gpt.chatStream,
      initialData: gpt.chat,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final bool isGenerating = gpt.messages.isNotEmpty &&
            gpt.messages.last.status == MessageStatus.streaming;

        return AnimatedSize(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchOutCurve: Curves.easeOutQuart,
            switchInCurve: Curves.easeOutQuart,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: isGenerating
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Stop generating response',
                          child: FilledButton.tonalIcon(
                            onPressed: gpt.stopGenerating,
                            icon: const Icon(Icons.stop_circle),
                            label: const Text('Stop generating'),
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
