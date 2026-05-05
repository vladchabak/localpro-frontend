import 'chat_api.dart';
import 'models/chat_model.dart';

class ChatRepository {
  final ChatApi _api;
  ChatRepository(this._api);

  Future<ChatSummaryModel> startChat({
    required String providerId,
    String? listingId,
  }) =>
      _api.startChat(providerId: providerId, listingId: listingId);

  Future<List<ChatSummaryModel>> getChats() => _api.getChats();

  Future<List<MessageModel>> getMessages(String chatId, {int page = 0}) =>
      _api.getMessages(chatId, page: page);

  Future<MessageModel> sendMessage(String chatId, String content) =>
      _api.sendMessage(chatId, content);

  Future<void> markRead(String chatId) => _api.markRead(chatId);
}
