import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../listing/domain/listing_providers.dart';
import '../data/models/booking_model.dart';
import '../domain/booking_providers.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
      ),
      body: bookingsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const LoadingSkeleton(height: 160, borderRadius: 18),
        ),
        error: (e, st) => AppErrorWidget(
          message: 'Failed to load bookings',
          onRetry: () => ref.invalidate(myBookingsProvider),
        ),
        data: (bookings) => bookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 48, color: AppColors.ink3),
                    const SizedBox(height: 16),
                    const Text('No bookings yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    const SizedBox(height: 8),
                    const Text('Browse services and make your first booking', style: TextStyle(fontSize: 14, color: AppColors.ink2)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/map'),
                      child: const Text('Explore Services'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
              ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final BookingResponse booking;

  const _BookingCard({required this.booking});

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.accent;
      case BookingStatus.confirmed:
        return AppColors.ok;
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
      case BookingStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () => context.push('/bookings/${booking.id}'),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0E1A1F).withValues(alpha: 0.04), blurRadius: 2),
          BoxShadow(color: const Color(0xFF0E1A1F).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 72,
                  height: 72,
                  color: AppColors.primarySoft,
                  child: const Icon(Icons.home_repair_service, size: 28, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.listingTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.providerName,
                      style: const TextStyle(fontSize: 12, color: AppColors.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(booking.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.status.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(booking.status),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.line),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date', style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM yyyy').format(booking.scheduledAt),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment', style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '€${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Cancel Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
          if (booking.status == BookingStatus.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showReviewSheet(context, ref),
                child: const Text('Leave a Review'),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelBooking(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(cancelBookingProvider(booking.id).future);
      if (context.mounted) {
        ref.invalidate(myBookingsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ReviewSheet(
        booking: booking,
        onSubmitted: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        ),
      ),
    );
  }
}

class _ReviewSheet extends ConsumerStatefulWidget {
  final BookingResponse booking;
  final VoidCallback onSubmitted;

  const _ReviewSheet({required this.booking, required this.onSubmitted});

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await ref.read(listingRepositoryProvider).submitReview(
        widget.booking.listingId,
        _rating,
        _commentController.text.trim(),
      );
      ref.invalidate(listingDetailProvider(widget.booking.listingId));
      if (mounted) {
        nav.pop();
        widget.onSubmitted();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review ${widget.booking.listingTitle}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: star <= _rating ? AppColors.primary : AppColors.line,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Tell others about your experience...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}
