import 'package:dio/dio.dart';
import 'models/chat_model.dart';

class ChatApi {
  final Dio _dio;
  ChatApi(this._dio);

  Future<ChatSummaryModel> startChat({
    required String providerId,
    String? listingId,
  }) async {
    final response = await _dio.post('/api/chats', data: {
      'providerId': providerId,
      if (listingId != null) 'listingId': listingId,
    });
    return ChatSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ChatSummaryModel>> getChats() async {
    final response = await _dio.get('/api/chats');
    return (response.data as List)
        .map((e) => ChatSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageModel>> getMessages(String chatId, {int page = 0}) async {
    final response = await _dio.get(
      '/api/chats/$chatId/messages',
      queryParameters: {'page': page, 'size': 30},
    );
    final content = response.data['content'] as List;
    return content
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage(String chatId, String content) async {
    final response = await _dio.post(
      '/api/chats/$chatId/messages',
      data: {'content': content},
    );
    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markRead(String chatId) async {
    await _dio.post('/api/chats/$chatId/read');
  }
}
