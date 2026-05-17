import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../core/api/api_endpoints.dart';
import 'models/chat_model.dart';

class StompService {
  StompClient? _client;
  final _messageController = StreamController<MessageModel>.broadcast();
  StompUnsubscribe? _roomSubscription;
  String? _userId;
  String? _token;
  int _reconnectAttempts = 0;

  Stream<MessageModel> get messageStream => _messageController.stream;

  bool get isConnected => _client?.connected ?? false;

  void connect({required String userId, required String token}) {
    _userId = userId;
    _token = token;
    _client = StompClient(
      config: StompConfig(
        url: kIsWeb ? ApiEndpoints.wsUrlWeb : ApiEndpoints.wsUrlAndroid,
        onConnect: (frame) {
          debugPrint('STOMP connected');
          _reconnectAttempts = 0;
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
        onDisconnect: (frame) {
          debugPrint('STOMP disconnected');
          _scheduleReconnect();
        },
        onStompError: (frame) => debugPrint('STOMP error: ${frame.body}'),
        onWebSocketError: (error) => debugPrint('WebSocket error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: Duration.zero,
      ),
    );
    _client!.activate();
  }

  void _scheduleReconnect() {
    if (_userId == null || _token == null) return;
    final delay = Duration(
      seconds: min(5 * (1 << _reconnectAttempts), 60),
    );
    Future.delayed(delay, () {
      if (_client != null && !_client!.connected) {
        _reconnectAttempts++;
        _client!.activate();
      }
    });
  }

  void subscribeToChat(String chatId) {
    _roomSubscription = _client?.subscribe(
      destination: '/topic/chats/$chatId',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final msg = MessageModel.fromJson(
              jsonDecode(frame.body!) as Map<String, dynamic>);
          _messageController.add(msg);
        } catch (e) {
          debugPrint('parse error: $e');
        }
      },
    );
  }

  void unsubscribeFromChat(String chatId) {
    _roomSubscription?.call();
    _roomSubscription = null;
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
