import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../managers/data/data_manager.dart';
import '../../managers/gpt_manager.dart';
import '../../models/chat_snippet.dart';
import '../../models/prompt.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/theme_extensions.dart';
import 'chat_section.dart';

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
      child: ChatScreen(
        prompt: prompt,
        chatID: chatID,
      ),
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
          'Either chatID or prompt must be provided, but not both nor neither.\nChatID: $chatID\nPrompt: $prompt',
        );

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool loading = false;
  String? error;

  final ScrollController scrollController = ScrollController();

  bool historyOpenOnWide = Hive.box(Constants.settings).get(
    Constants.openHistoryOnWideScreen,
    defaultValue: true,
  );

  Future<void> unSave() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await DataManager.instance.unSavePrompt(promptID: widget.prompt!.id);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final GPTManager gpt = context.read<GPTManager>();
    gpt.loadHistory();

    gpt.openChat(
      notify: false,
      prompt: widget.prompt,
      chatID: widget.chatID,
    );
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chatID != widget.chatID ||
        oldWidget.prompt != widget.prompt) {
      final GPTManager gpt = context.read<GPTManager>();
      gpt.stopGenerating();
      gpt.openChat(
        notify: true,
        prompt: widget.prompt,
        chatID: widget.chatID,
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GPTManager gpt = context.watch<GPTManager>();

    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 800;
      return CustomScaffold(
        extendBodyBehindAppBar: true,
        leading: ScaffoldAction(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onTap: () {
            context.go('/home', extra: {'from': '/chat'});
          },
        ),
        title: Text(
          widget.prompt?.title ?? 'Loading...',
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: false,
        actions: [
          ScaffoldAction(
            tooltip: 'Unsave',
            icon: Icons.favorite,
            onTap: () {
              unSave();
              context.go('/home', extra: {'from': '/chat'});
            },
          ),
          if (isWide && !historyOpenOnWide)
            ScaffoldAction(
              tooltip: 'Chat History',
              onTap: () {
                historyOpenOnWide = !historyOpenOnWide;
                Hive.box(Constants.settings).put(
                  Constants.openHistoryOnWideScreen,
                  historyOpenOnWide,
                );
                setState(() {});
              },
              icon: Icons.history,
            ),
          if (!isWide)
            Builder(
              builder: (context) {
                return ScaffoldAction(
                  tooltip: 'Chat History',
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: Icons.history,
                );
              },
            ),
          ScaffoldAction(
            tooltip: 'New Chat',
            onTap: () {
              gpt.openChat(notify: true, prompt: widget.prompt);
            },
            icon: Icons.add,
          ),
        ],
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
                                  .instance.currentUser!.chatSnippets.values
                                  .sorted((a, b) =>
                                      b.updatedOn.compareTo(a.updatedOn))) ...[
                                const Divider(height: 1),
                                HistoryTile(chatSnippet: chatSnippet),
                              ]
                            ]),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
        body: Builder(builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context)
                  .textTheme
                  .merge(GoogleFonts.robotoTextTheme()),
            ),
            child: SizedBox.expand(
              child: Row(
                children: [
                  Expanded(
                    child: ChatSection(
                      scrollController: scrollController,
                    ),
                  ),
                  if (isWide && historyOpenOnWide)
                    SizedBox(
                      width: 300,
                      child: Drawer(
                        child: Column(
                          children: [
                            SizedBox(
                                height: Scaffold.of(context).appBarMaxHeight),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  ScaffoldAction(
                                    onTap: () {
                                      historyOpenOnWide = !historyOpenOnWide;
                                      Hive.box(Constants.settings).put(
                                        Constants.openHistoryOnWideScreen,
                                        historyOpenOnWide,
                                      );
                                      setState(() {});
                                    },
                                    icon: Icons.last_page,
                                    tooltip: 'Close History',
                                    color: context.colorScheme.onSurface,
                                    hoverColor: context
                                        .colorScheme.primaryContainer
                                        .withOpacity(0.25),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chat History',
                                    style: context.textTheme.titleSmall,
                                  ),
                                ],
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
              ),
            ),
          );
        }),
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
        // leading: AssetManager.getPromptIcon(
        //   widget.chatSnippet.promptIcon,
        //   size: 20,
        //   color: isActiveChat
        //       ? context.colorScheme.onPrimaryContainer
        //       : context.colorScheme.onBackground,
        // ),
        title: Text(
          widget.chatSnippet.snippet,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: isActiveChat
                ? context.colorScheme.onPrimaryContainer
                : context.colorScheme.onBackground,
          ),
        ),
        onTap: () {
          context.go(
            '/chat?chatID=${widget.chatSnippet.id}',
            extra: {
              'from': '/chat?chatID=${gpt.chat?.id}',
            },
          );
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
