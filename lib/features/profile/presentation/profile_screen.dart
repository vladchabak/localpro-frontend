import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../auth/domain/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load profile.',
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (user) => ListView(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(
                            user.role,
                            style: const TextStyle(fontSize: 11),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Menu items
            ListTile(
              leading: const Icon(
                Icons.home_repair_service,
                color: AppColors.primary,
              ),
              title: const Text('My Services'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/provider/dashboard'),
            ),
            ListTile(
              leading: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
              ),
              title: const Text('My Chats'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/chats'),
            ),
            ListTile(
              leading: const Icon(
                Icons.payment,
                color: AppColors.primary,
              ),
              title: const Text('Payments'),
              trailing: Chip(
                label: const Text(
                  'Coming soon',
                  style: TextStyle(fontSize: 11),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.background,
              ),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payments coming soon!')),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Sign out',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => context.go('/auth/login'),
            ),
          ],
        ),
      ),
    );
  }
}
