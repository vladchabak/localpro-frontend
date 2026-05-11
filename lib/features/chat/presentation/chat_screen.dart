import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_providers.dart';
import '../data/models/chat_model.dart';
import '../domain/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? listingTitle;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.listingTitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<MessageModel>? _messageSubscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final user = await ref.read(currentUserProvider.future);
      if (!mounted) return;
      _currentUserId = user.id;

      final messages =
          await ref.read(chatMessagesProvider(widget.chatId).future);
      if (!mounted) return;
      ref
          .read(chatMessageListProvider(widget.chatId).notifier)
          .setInitialMessages(messages);
      ref.read(chatRepositoryProvider).markRead(widget.chatId);

      final stomp = ref.read(stompServiceProvider);
      if (!stomp.isConnected) {
        stomp.connect(userId: user.id);
      }

      _messageSubscription = stomp.messageStream.listen((message) {
        if (message.chatId == widget.chatId) {
          ref
              .read(chatMessageListProvider(widget.chatId).notifier)
              .addMessage(message);
          _scrollToBottom();
        }
      });

      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    _messageController.clear();

    final optimistic = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chatId,
      senderId: _currentUserId ?? 'unknown',
      senderName: 'Me',
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );
    ref
        .read(chatMessageListProvider(widget.chatId).notifier)
        .addMessage(optimistic);
    _scrollToBottom();

    final stomp = ref.read(stompServiceProvider);
    if (stomp.isConnected) {
      stomp.sendMessage(chatId: widget.chatId, content: content);
    } else {
      try {
        final message = await ref
            .read(chatRepositoryProvider)
            .sendMessage(widget.chatId, content);
        ref
            .read(chatMessageListProvider(widget.chatId).notifier)
            .replaceOptimistic(optimistic.id, message);
      } catch (e) {
        debugPrint('Failed to send message: $e');
      }
    }
  }

  String _getOtherPartyName() {
    final chatsAsync = ref.watch(chatsProvider);
    return chatsAsync.maybeWhen(
      data: (chats) {
        try {
          return chats
              .firstWhere((c) => c.id == widget.chatId)
              .otherPartyName;
        } catch (_) {
          return 'Chat';
        }
      },
      orElse: () => 'Chat',
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessageListProvider(widget.chatId));
    final otherPartyName = _getOtherPartyName();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherPartyName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.listingTitle != null)
              Text(
                widget.listingTitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Send a message to start the conversation',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _MessageBubble(
                      message: messages[i],
                      currentUserId: _currentUserId ?? '',
                    ),
                  ),
          ),
          _InputBar(
            controller: _messageController,
            onSend: () { _sendMessage(); },
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String currentUserId;

  const _MessageBubble({required this.message, required this.currentUserId});

  String _timeString(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == currentUserId;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundImage: message.senderAvatarUrl != null
                  ? CachedNetworkImageProvider(message.senderAvatarUrl!)
                  : null,
              child: message.senderAvatarUrl == null
                  ? Text(
                      message.senderName.isNotEmpty
                          ? message.senderName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeString(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
