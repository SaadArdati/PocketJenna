import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../managers/asset_manager.dart';
import '../managers/data/data_manager.dart';
import '../managers/gpt_manager.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_snippet.dart';
import '../models/message_status.dart';
import '../models/prompt.dart';
import '../ui/markdown_renderer.dart';
import '../ui/theme_extensions.dart';
import '../ui/window_controls.dart';

class ChatScreenWrapper extends StatelessWidget {
  final Prompt? prompt;
  final String? chatID;

  const ChatScreenWrapper({
    super.key,
    this.chatID,
    this.prompt,
  }) : assert(
          (chatID == null) != (prompt == null),
          'Either chatID or prompt must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GPTManager>(
      create: (context) => GPTManager(),
      child: ChatScreen(prompt: prompt),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Prompt? prompt;
  final String? chatID;

  const ChatScreen({
    super.key,
    this.prompt,
    this.chatID,
  }) : assert(
          (chatID == null) != (prompt == null),
          'Either chatID or prompt must be provided',
        );

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  late final Stream<Chat?> chatStream;

  bool historyOpenOnWide = Hive.box(Constants.settings).get(
    Constants.openHistoryOnWideScreen,
    defaultValue: true,
  );

  @override
  void initState() {
    super.initState();

    final GPTManager gpt = context.read<GPTManager>();

    gpt.init();

    chatStream = gpt.chatStream;

    gpt.openChat(
      notify: false,
      prompt: widget.prompt,
      chatID: widget.chatID,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();

    final GPTManager gpt = context.read<GPTManager>();
    gpt.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.watch<GPTManager>();

    final TargetPlatform platform = defaultTargetPlatform;
    final bool isDesktop = !kIsWeb &&
        (platform == TargetPlatform.windows ||
            platform == TargetPlatform.linux ||
            platform == TargetPlatform.macOS);

    final double? buttonSize = isDesktop ? 20 : null;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 800;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: context.colorScheme.primary,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              context.go('/home', extra: {'from': 'chat'});
            },
          ),
          title: Text(
            widget.prompt?.title ?? 'Loading...',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
          centerTitle: false,
          actions: [
            if (isWide)
              Padding(
                padding: EdgeInsets.only(right: historyOpenOnWide ? 142 : 0),
                child: IconButton(
                  iconSize: buttonSize,
                  tooltip: 'Chat History',
                  onPressed: () {
                    historyOpenOnWide = !historyOpenOnWide;
                    Hive.box(Constants.settings).put(
                      Constants.openHistoryOnWideScreen,
                      historyOpenOnWide,
                    );
                    setState(() {});
                  },
                  icon: Icon(
                    historyOpenOnWide ? Icons.arrow_forward_ios : Icons.history,
                    size: historyOpenOnWide ? 16 : null,
                  ),
                ),
              ),
            if (!isWide)
              Builder(
                builder: (context) {
                  return IconButton(
                    iconSize: buttonSize,
                    tooltip: 'Chat History',
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.history),
                  );
                },
              ),
            IconButton(
              iconSize: buttonSize,
              tooltip: 'New Chat',
              onPressed: () {
                gpt.openChat(notify: true, prompt: widget.prompt);
              },
              icon: const Icon(Icons.add),
            ),
            const WindowControls(),
          ],
        ),
        endDrawerEnableOpenDragGesture: false,
        endDrawer: isWide
            ? null
            : ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Builder(builder: (context) {
                  return Drawer(
                    child: SafeArea(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              'Chat History',
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: ListView(children: [
                              for (final ChatSnippet chatSnippet in DataManager
                                  .instance.currentUser!.chatSnippets.values)
                                HistoryTile(chatSnippet: chatSnippet),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
        body: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context)
                .textTheme
                .merge(GoogleFonts.robotoTextTheme()),
          ),
          child: SizedBox.expand(
            child: StreamBuilder<Chat?>(
                stream: chatStream,
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

                  final fullChat = gpt.chat!.toFullChat..removeAt(0);
                  final bool isGenerating = gpt.messages.isNotEmpty &&
                      gpt.messages.last.status == MessageStatus.streaming;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: SelectionArea(
                                child: ListView.separated(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  controller: scrollController,
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                              ),
                            ),
                            AnimatedSize(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Tooltip(
                                              message:
                                                  'Stop generating response',
                                              child: FilledButton.tonalIcon(
                                                onPressed: gpt.stopGenerating,
                                                icon: const Icon(
                                                    Icons.stop_circle),
                                                label: const Text(
                                                    'Stop generating'),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            const UserInteractionRegion(),
                          ],
                        ),
                      ),
                      if (isWide && historyOpenOnWide)
                        SizedBox(
                          width: 300,
                          child: Drawer(
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(18),
                                  child: Text(
                                    'Chat History',
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      for (final ChatSnippet chatSnippet
                                          in DataManager.instance.currentUser!
                                              .chatSnippets.values)
                                        HistoryTile(chatSnippet: chatSnippet),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }),
          ),
        ),
      );
    });
  }
}

class HistoryTile extends StatefulWidget {
  const HistoryTile({
    super.key,
    required this.chatSnippet,
  });

  final ChatSnippet chatSnippet;

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.watch<GPTManager>();
    final bool isActiveChat = widget.chatSnippet.id == gpt.chat?.id;
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovering = false;
        });
      },
      child: ListTile(
        horizontalTitleGap: 0,
        leading: AssetManager.getPromptIcon(
          widget.chatSnippet.prompt,
          size: 20,
          color: isActiveChat
              ? context.colorScheme.onPrimaryContainer
              : context.colorScheme.onBackground,
        ),
        title: Text(
          widget.chatSnippet.snippet,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall,
        ),
        onTap: () {
          gpt.openChat(chatID: widget.chatSnippet.id, notify: true);
          Scaffold.of(context).closeEndDrawer();
        },
        onLongPress: () {
          // Delete with a confirmation dialog
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Delete Chat'),
                    content: const Text(
                        'Are you sure you want to delete this chat?'),
                    actions: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: context.colorScheme.onBackground),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                        onPressed: () {
                          gpt.deleteChat(widget.chatSnippet.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ));
        },
        selected: isActiveChat,
        selectedTileColor: context.colorScheme.primaryContainer,
        selectedColor: context.colorScheme.onPrimaryContainer,
        trailing: !isHovering
            ? isActiveChat
                ? IconButton(
                    tooltip: 'Currently active chat',
                    icon: Icon(
                      Icons.chat,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                    iconSize: 20,
                    onPressed: null,
                  )
                : null
            : IconButton(
                tooltip: 'Delete chat',
                iconSize: 20,
                icon: Icon(Icons.delete, color: context.colorScheme.error),
                onPressed: () {
                  gpt.deleteChat(widget.chatSnippet.id);
                },
              ),
      ),
    );
  }
}

class UserInteractionRegion extends StatefulWidget {
  const UserInteractionRegion({super.key});

  @override
  State<UserInteractionRegion> createState() => _UserInteractionRegionState();
}

class _UserInteractionRegionState extends State<UserInteractionRegion> {
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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Audio recording'),
            content: const Text(
              'This feature is coming soon! Type a message to show the send button.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Dismiss',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onBackground,
                  ),
                ),
              ),
            ],
          );
        },
      );
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

    final bool isGenerating = gpt.messages.isNotEmpty &&
        gpt.messages.last.status == MessageStatus.streaming;
    return Form(
      child: Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Add Attachment'),
                            content: const Text(
                              'This feature is coming soon!',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Dismiss',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onBackground,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
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
                          fillColor: context.colorScheme.primaryContainer
                              .withOpacity(0.5),
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

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (message.role) {
      case OpenAIChatMessageRole.user:
        child = UserMessageBubble(message: message);
        break;
      case OpenAIChatMessageRole.system:
        child = SystemMessageBubble(message: message);
        break;
      case OpenAIChatMessageRole.assistant:
        child = AssistantMessageBubble(message: message);
        break;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      ),
    );
  }
}

class SystemMessageBubble extends StatelessWidget {
  const SystemMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Bubble(
        showNip: false,
        color: context.colorScheme.tertiary,
        child: MarkdownText(
          text: message.text,
          style: TextStyle(
            color: context.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}

class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(left: 32),
      child: Bubble(
        showNip: true,
        nip: BubbleNip.rightTop,
        color: context.colorScheme.secondaryContainer,
        child: MarkdownText(
          text: message.text,
          style: TextStyle(
            color: context.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.read<GPTManager>();
    final Widget child;
    if (message.status == MessageStatus.streaming) {
      child = StreamBuilder<ChatMessage?>(
        stream: gpt.responseStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return buildErrorBubble(context, snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final ChatMessage streamingMessage = snapshot.data!;
          switch (streamingMessage.status) {
            case MessageStatus.waiting:
              return const SizedBox.shrink();
            case MessageStatus.errored:
              return buildErrorBubble(context, streamingMessage.text);
            case MessageStatus.streaming:
            case MessageStatus.done:
              return buildConversationBubble(context, streamingMessage);
          }
        },
      );
    } else {
      child = buildConversationBubble(context, message);
    }

    final bool showRegenButton = gpt.messages.last.id == message.id &&
        message.status != MessageStatus.streaming;
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(right: showRegenButton ? 0 : 32),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(child: child),
          if (showRegenButton) ...[
            IconButton(
              tooltip: 'Regenerate',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                gpt.regenerateLastResponse();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget buildConversationBubble(BuildContext context, ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Bubble(
        showNip: true,
        nip: BubbleNip.leftTop,
        color: context.colorScheme.primaryContainer,
        child: MarkdownText(
          text: message.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget buildErrorBubble(BuildContext context, String text) {
    return Bubble(
      color: context.colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error_outline, size: 14),
              SizedBox(width: 4),
              Text(
                'An error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          Text(
            text,
            style: TextStyle(
              color: context.colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
