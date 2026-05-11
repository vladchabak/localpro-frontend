import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/test_user_provider.dart';
import '../theme/app_colors.dart';
import '../../features/auth/domain/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/booking/presentation/booking_success_screen.dart';
import '../../features/booking/presentation/my_bookings_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/listing/data/models/listing_detail_model.dart';
import '../../features/listing/presentation/create_listing_screen.dart';
import '../../features/listing/presentation/listing_detail_screen.dart';
import '../../features/listing/presentation/verification_prompt_screen.dart';
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
      path: '/listings/verify/:id',
      builder: (context, state) => VerificationPromptScreen(
        listingId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/provider/dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) => BookingScreen(
        listing: state.extra as ListingDetailModel,
      ),
    ),
    GoRoute(
      path: '/booking/success/:id',
      builder: (context, state) => BookingSuccessScreen(
        bookingId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const MyBookingsScreen(),
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
    // Test user bypasses Firebase — go straight to the app.
    final testUser = ref.watch(testUserNotifierProvider);
    if (testUser != null) {
      Future.microtask(() {
        if (context.mounted) context.go('/map');
      });
      return const Scaffold(backgroundColor: Colors.white);
    }

    final authState = ref.watch(authStateProvider);

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
      error: (e, _) {
        Future.microtask(() {
          if (context.mounted) context.go('/auth/login');
        });
        return const Scaffold(backgroundColor: Colors.white);
      },
      data: (user) {
        Future.microtask(() {
          if (context.mounted) {
            context.go(user != null ? '/map' : '/auth/login');
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: BottomNavigationBar(
          currentIndex: _locationToIndex(path),
          onTap: (i) => context.go(_tabs[i]),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: _NavBadge(child: const Icon(Icons.chat_bubble_outline), count: 2),
              activeIcon: _NavBadge(child: const Icon(Icons.chat_bubble), count: 2),
              label: 'Messages',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  final Widget child;
  final int count;
  const _NavBadge({required this.child, required this.count});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      child,
      if (count > 0)
        Positioned(
          top: -3, right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.card, width: 1.5),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
            ),
          ),
        ),
    ],
  );
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
