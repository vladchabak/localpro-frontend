import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/booking_providers.dart';

class BookingSuccessScreen extends ConsumerWidget {
  final String bookingId;

  const BookingSuccessScreen({super.key, required this.bookingId});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed'), elevation: 0),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load booking'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.go('/map'), child: const Text('Back to Home')),
            ],
          ),
        ),
        data: (booking) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Checkmark animation
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.check_circle, size: 60, color: AppColors.ok),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking has been created successfully',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.ink2),
              ),
              const SizedBox(height: 24),

              // Booking details card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow('Service', booking.listingTitle),
                    const SizedBox(height: 12),
                    _DetailRow('Provider', booking.providerName),
                    const SizedBox(height: 12),
                    _DetailRow('Date & Time', booking.scheduledAt.toString().split('.')[0]),
                    const SizedBox(height: 12),
                    _DetailRow('Total Price', '€${booking.totalPrice.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _DetailRow(
                      'Status',
                      booking.status.toString().split('.').last.toUpperCase(),
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow('Booking ID', '#${booking.id.substring(0, 8)}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Calendar buttons
              if (booking.calendlyUrl != null || booking.googleCalendarUrl != null) ...[
                Text('Add to calendar', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.8)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (booking.calendlyUrl != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(booking.calendlyUrl!),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Calendly'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    if (booking.calendlyUrl != null && booking.googleCalendarUrl != null) const SizedBox(width: 12),
                    if (booking.googleCalendarUrl != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(booking.googleCalendarUrl!),
                          icon: const Icon(Icons.event_note, size: 18),
                          label: const Text('Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              ElevatedButton(
                onPressed: () => context.go('/map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/bookings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('View My Bookings'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.ink2)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.ink)),
    ],
  );
}
