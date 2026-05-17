import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/test_user_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_banner.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'LocalPro',
      theme: AppTheme.light,
      routerConfig: appRouter,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final testUser = ref.watch(testUserNotifierProvider);
        if (testUser == null) return ConnectivityBanner(child: child!);

        final topPadding = MediaQuery.of(context).padding.top;
        return Column(
          children: [
            Container(
              color: const Color(0xFFF57C00),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12, topPadding + 4, 12, 6),
              child: Text(
                '🧪 Test Mode — logged in as ${testUser.displayName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Expanded(
              child: ConnectivityBanner(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: MediaQuery.of(context).padding.copyWith(top: 0),
                  ),
                  child: child!,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
