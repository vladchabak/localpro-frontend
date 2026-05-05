import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/domain/auth_providers.dart';
import '../data/chat_api.dart';
import '../data/chat_repository.dart';
import '../data/models/chat_model.dart';
import '../data/stomp_service.dart';

part 'chat_providers.g.dart';

@riverpod
ChatApi chatApi(ChatApiRef ref) => ChatApi(ref.watch(dioProvider));

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) =>
    ChatRepository(ref.watch(chatApiProvider));

@Riverpod(keepAlive: true)
StompService stompService(StompServiceRef ref) {
  final service = StompService();
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
Future<List<ChatSummaryModel>> chats(ChatsRef ref) =>
    ref.watch(chatRepositoryProvider).getChats();

@riverpod
Future<List<MessageModel>> chatMessages(
  ChatMessagesRef ref,
  String chatId,
) async {
  await ref.read(chatRepositoryProvider).markRead(chatId);
  return ref.read(chatRepositoryProvider).getMessages(chatId);
}

@riverpod
class ChatMessageList extends _$ChatMessageList {
  @override
  List<MessageModel> build(String chatId) => [];

  void addMessage(MessageModel message) {
    state = [...state, message];
  }

  void setInitialMessages(List<MessageModel> messages) {
    // API returns newest-first; reverse for chronological display
    state = messages.reversed.toList();
  }

  void replaceOptimistic(String tempId, MessageModel real) {
    state = state.map((m) => m.id == tempId ? real : m).toList();
  }
}
