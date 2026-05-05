import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/app_error_widget.dart';
import '../../features/auth/domain/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/listing/presentation/create_listing_screen.dart';
import '../../features/listing/presentation/listing_detail_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/provider_dashboard/presentation/provider_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/chats',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/listings/:id',
      builder: (context, state) => ListingDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/chats/:id',
      builder: (context, state) => ChatScreen(
        chatId: state.pathParameters['id']!,
        listingTitle: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/provider/listings/create',
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: '/provider/dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);

// Splash screen

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(isAuthenticatedProvider);

    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LocalPro',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        body: AppErrorWidget(
          message: 'Cannot connect to server.\nMake sure backend is running.',
          onRetry: () => ref.invalidate(isAuthenticatedProvider),
        ),
      ),
      data: (isAuth) {
        Future.microtask(() {
          if (context.mounted) {
            context.go(isAuth ? '/map' : '/auth/login');
          }
        });
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(
              'LocalPro',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Home shell with bottom nav

class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _tabs = ['/map', '/catalog', '/chats', '/profile'];

  int _locationToIndex(String path) {
    if (path.startsWith('/catalog')) return 1;
    if (path.startsWith('/chats')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _locationToIndex(path),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: (i) => context.go(_tabs[i]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Catalog'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens (replaced in later phases)

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Catalog — coming soon')),
      );
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Edit Profile — coming soon')),
      );
}
