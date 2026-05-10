import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../core/api/api_endpoints.dart';
import 'models/chat_model.dart';

class StompService {
  StompClient? _client;
  final _messageController = StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get messageStream => _messageController.stream;

  bool get isConnected => _client?.connected ?? false;

  void connect({required String userId}) {
    _client = StompClient(
      config: StompConfig(
        url: kIsWeb ? ApiEndpoints.wsUrlWeb : ApiEndpoints.wsUrlAndroid,
        onConnect: (frame) {
          debugPrint('STOMP connected');
          _client!.subscribe(
            destination: '/user/$userId/queue/messages',
            callback: (frame) {
              if (frame.body != null) {
                try {
                  final json =
                      jsonDecode(frame.body!) as Map<String, dynamic>;
                  final message = MessageModel.fromJson(json);
                  _messageController.add(message);
                } catch (e) {
                  debugPrint('Failed to parse message: $e');
                }
              }
            },
          );
        },
        onDisconnect: (frame) => debugPrint('STOMP disconnected'),
        onStompError: (frame) => debugPrint('STOMP error: ${frame.body}'),
        onWebSocketError: (error) => debugPrint('WebSocket error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer dev-token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer dev-token'},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _client!.activate();
  }

  void sendMessage({required String chatId, required String content}) {
    if (!isConnected) {
      debugPrint('STOMP not connected, cannot send message');
      return;
    }
    _client!.send(
      destination: '/app/chat.send',
      body: jsonEncode({'chatId': chatId, 'content': content}),
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
