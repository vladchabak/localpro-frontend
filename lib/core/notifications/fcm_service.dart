import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../../app.dart';

class FcmService {
  static Future<void> Function(String)? _onToken;

  static void setTokenUpload(Future<void> Function(String) fn) {
    _onToken = fn;
  }

  static Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      debugPrint('FCM token: $token');

      messaging.onTokenRefresh.listen((t) {
        if (!kIsWeb && FirebaseAuth.instance.currentUser != null) {
          _onToken?.call(t).catchError((_) {});
        }
      });

      // Foreground messages
      FirebaseMessaging.onMessage.listen((msg) {
        final n = msg.notification;
        if (n == null) return;
        _showInAppBanner(n.title ?? 'New message', msg.data);
      });

      // Background tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

      // Terminated-state tap
      final initial = await messaging.getInitialMessage();
      if (initial != null) _handleTap(initial);
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  static void _handleTap(RemoteMessage msg) {
    final chatId = msg.data['chatId'] as String?;
    if (chatId != null) {
      appRouter.go('/chats/$chatId');
    } else {
      appRouter.go('/chats');
    }
  }

  static void _showInAppBanner(String title, Map<String, dynamic> data) {
    final chatId = data['chatId'] as String?;
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(title),
        action: chatId != null
            ? SnackBarAction(
                label: 'Open',
                onPressed: () => appRouter.go('/chats/$chatId'))
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
