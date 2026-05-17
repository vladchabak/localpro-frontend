import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../auth/domain/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(authRepositoryProvider).updateProfile({
        'name': name,
        if (_bioController.text.trim().isNotEmpty) 'bio': _bioController.text.trim(),
        if (_phoneController.text.trim().isNotEmpty) 'phone': _phoneController.text.trim(),
      });
      ref.invalidate(currentUserProvider);
      if (mounted) router.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: AppErrorWidget(
          message: 'Failed to load profile.',
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
      ),
      data: (user) {
        if (!_initialized) {
          _nameController.text = user.name;
          _bioController.text = user.bio ?? '';
          _phoneController.text = user.phone ?? '';
          _initialized = true;
        }

        final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              TextButton(
                onPressed: _submitting ? null : _save,
                child: const Text('Save'),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Avatar section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Photo upload coming soon',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    const _FieldLabel('Name *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      maxLength: 100,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'Your name'),
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    const _FieldLabel('Bio'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLength: 300,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Tell clients about yourself'),
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    const _FieldLabel('Phone'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: '+1 555 000 0000'),
                    ),
                  ],
                ),
              ),

              // Sticky save button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _save,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
}
