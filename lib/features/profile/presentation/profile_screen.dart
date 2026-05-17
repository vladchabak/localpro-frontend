import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/test_user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../auth/domain/auth_providers.dart';
import '../../listing/domain/listing_providers.dart';

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
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit profile',
                    onPressed: () => context.push('/profile/edit'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // My Services Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.home_repair_service, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text(
                    'My Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/provider/dashboard'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final myListingsAsync = ref.watch(myListingsProvider);
                return myListingsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading services'),
                  ),
                  data: (listings) {
                    if (listings.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'No services yet',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/provider/listings/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Service'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listings.length,
                      itemBuilder: (_, i) {
                        final listing = listings[i];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listing.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            listing.categoryName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (listing.price != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '€${listing.price}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: listing.isVerified
                                            ? const Color(0xFFD4EDDA)
                                            : const Color(0xFFFFF3CD),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        listing.isVerified
                                            ? '✓ Verified'
                                            : '⚠ Not Verified',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: listing.isVerified
                                              ? const Color(0xFF155724)
                                              : const Color(0xFF856404),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!listing.isVerified) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '⚠ Not visible on map',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(0xFFFF9800),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const Divider(height: 1),

            // Menu items
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
              ),
              title: const Text('Add New Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/provider/listings/create'),
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
            Consumer(
              builder: (context, ref, _) {
                final testUser = ref.watch(testUserNotifierProvider);
                if (testUser == null) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.science_outlined, color: Color(0xFFF57C00)),
                  title: const Text(
                    'Exit Test Mode',
                    style: TextStyle(
                      color: Color(0xFFF57C00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    ref.read(testUserNotifierProvider.notifier).logout();
                    context.go('/auth/login');
                  },
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Sign out',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/auth/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
