import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityBanner extends ConsumerWidget {
  final Widget child;
  const ConnectivityBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: isOnline
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  color: const Color(0xFFF57C00),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Text(
                    'No internet connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
