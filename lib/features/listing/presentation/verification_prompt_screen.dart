import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/listing_providers.dart';

class VerificationPromptScreen extends ConsumerStatefulWidget {
  final String listingId;

  const VerificationPromptScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<VerificationPromptScreen> createState() =>
      _VerificationPromptScreenState();
}

class _VerificationPromptScreenState
    extends ConsumerState<VerificationPromptScreen> {
  bool _isVerifying = false;
  bool _isVerified = false;

  Future<void> _verifyListing() async {
    setState(() => _isVerifying = true);
    try {
      await ref
          .read(listingRepositoryProvider)
          .verifyListing(widget.listingId);
      if (!mounted) return;
      setState(() => _isVerified = true);
      ref.invalidate(myListingsProvider);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/provider/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Listing'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/provider/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            if (!_isVerified)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  border: Border.all(color: const Color(0xFFFFE082)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFFA500)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your listing is not visible on map yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xE8D4EDDA),
                  border: Border.all(color: const Color(0xFFC3E6CB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Color(0xFF28A745), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Listing verified!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF155724),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            const Icon(
              Icons.location_on_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Get Verified!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isVerified
                  ? 'Your listing is now visible on the map and customers can find you!'
                  : 'Verify your listing to appear on the map and get more customers.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isVerifying || _isVerified ? null : _verifyListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isVerified ? const Color(0xFF28A745) : AppColors.primary,
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isVerified ? '✓ Verified!' : 'Verify My Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () => context.go('/provider/dashboard'),
                child: const Text(
                  'Go to My Listings',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
