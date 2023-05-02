import 'package:bubble/bubble.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../managers/gpt_manager.dart';
import '../../models/chat_message.dart';
import '../../models/message_status.dart';
import '../../ui/markdown_renderer.dart';
import '../../ui/theme_extensions.dart';

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

    final bool showRegenButton = gpt.chat != null &&
        gpt.messages.last.id == message.id &&
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
