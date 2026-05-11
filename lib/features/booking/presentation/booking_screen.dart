import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../listing/data/models/listing_detail_model.dart';
import '../data/models/booking_model.dart';
import '../domain/booking_providers.dart';
import 'widgets/in_app_time_picker.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final ListingDetailModel listing;

  const BookingScreen({super.key, required this.listing});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  DateTime? _inAppSelectedDateTime;
  CalendarType? _selectedCalendarType;
  PaymentType _selectedPayment = PaymentType.creditCard;
  final _notesController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = TimeOfDay.now();
    _autoFillMockCard();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _autoFillMockCard() {
    final random = Random();
    final cardNumbers = [
      '4532 1234 5678 9012',
      '5425 2334 3010 9903',
      '4916 3384 0813 7678',
      '4024 0071 2345 6789',
    ];
    final expiries = ['12/26', '08/27', '03/28', '11/26'];
    final cvvs = ['123', '456', '789', '321'];

    _cardNumberController.text = cardNumbers[random.nextInt(cardNumbers.length)];
    _expiryController.text = expiries[random.nextInt(expiries.length)];
    _cvvController.text = cvvs[random.nextInt(cvvs.length)];
    _cardHolderController.text = 'TEST USER';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _launchCalendar(String calendarType) async {
    final url = calendarType == 'calendly'
        ? 'https://calendly.com/mock-booking'
        : 'https://calendar.google.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showInAppTimePicker() async {
    final selectedDateTime = await InAppTimePicker.show(context);
    if (selectedDateTime != null) {
      setState(() {
        _inAppSelectedDateTime = selectedDateTime;
        _selectedCalendarType = CalendarType.inApp;
      });
    }
  }

  String _formatInAppDateTime(DateTime dateTime) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[dateTime.weekday - 1];
    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '📅 $dayName, ${_formatDateMonthDay(dateTime)} at $timeString';
  }

  String _formatDateMonthDay(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  Future<void> _confirmBooking() async {
    // Check listing ID
    if (widget.listing.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid listing. Please go back and try again.')),
      );
      return;
    }

    // Check card details if credit card is selected
    if (_selectedPayment == PaymentType.creditCard &&
        (_cardNumberController.text.isEmpty ||
            _expiryController.text.isEmpty ||
            _cvvController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all card details')),
      );
      return;
    }

    // Build scheduled date/time
    DateTime? scheduledAt;
    if (_inAppSelectedDateTime != null) {
      scheduledAt = _inAppSelectedDateTime;
    } else {
      scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    }

    final calendarType = _selectedCalendarType ?? CalendarType.googleCalendar;

    setState(() => _isProcessingPayment = true);
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      // Validate and build request with safe type conversion
      final String validListingId = widget.listing.id.toString();
      if (validListingId.isEmpty) {
        throw Exception('Invalid listing ID');
      }

      if (scheduledAt == null) {
        throw Exception('Scheduled date/time is not set');
      }

      final request = BookingRequest(
        listingId: validListingId,
        scheduledAt: scheduledAt,
        paymentType: _selectedPayment,
        calendarType: calendarType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Validate request before sending
      final requestJson = request.toJson();
      debugPrint('🔵 Booking request JSON: ${jsonEncode(requestJson)}');
      debugPrint('📅 Scheduled at: ${request.scheduledAt.toIso8601String()}');
      debugPrint('💳 Payment type: ${request.paymentType} (${requestJson['paymentType']})');
      debugPrint('📍 Calendar type: ${request.calendarType} (${requestJson['calendarType']})');
      debugPrint('📍 Listing ID: ${request.listingId}');

      final response = await ref.read(createBookingProvider(request).future);

      if (mounted) {
        context.go('/booking/success/${response.id}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Booking error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.listing.price ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listing summary
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 84,
                      height: 84,
                      color: AppColors.primarySoft,
                      child: const Icon(Icons.home_repair_service, size: 32, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.listing.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.listing.providerName,
                          style: const TextStyle(fontSize: 13, color: AppColors.ink2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${totalPrice.toStringAsFixed(2)}/hr',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date & time picker
            Text('Schedule', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.8).copyWith(fontSize: 11)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    label: 'Date',
                    value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerButton(
                    label: 'Time',
                    value: _selectedTime.format(context),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Calendar integration
            Text('Add to calendar', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.8).copyWith(fontSize: 11)),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CalendarButton(
                        label: 'Calendly',
                        icon: Icons.calendar_today,
                        onTap: () => _launchCalendar('calendly'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CalendarButton(
                        label: 'Google Calendar',
                        icon: Icons.event_note,
                        onTap: () => _launchCalendar('google'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _CalendarButton(
                    label: 'Choose time in app',
                    icon: Icons.schedule,
                    onTap: _showInAppTimePicker,
                  ),
                ),
              ],
            ),
            if (_inAppSelectedDateTime != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatInAppDateTime(_inAppSelectedDateTime!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Payment method
            Text('Payment method', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.8).copyWith(fontSize: 11)),
            const SizedBox(height: 8),
            _PaymentMethodSelector(
              selectedPayment: _selectedPayment,
              onChanged: (payment) {
                setState(() => _selectedPayment = payment);
                if (payment == PaymentType.creditCard) {
                  _autoFillMockCard();
                }
              },
              cardNumberController: _cardNumberController,
              expiryController: _expiryController,
              cvvController: _cvvController,
              cardHolderController: _cardHolderController,
            ),
            const SizedBox(height: 24),

            // Notes
            Text('Notes (optional)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.8).copyWith(fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add any special requests...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: AppColors.card,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Total price
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  Text(
                    '€${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : _confirmBooking,
                child: _isProcessingPayment
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Confirm Booking'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerButton({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.ink3, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    ),
  );
}

class _CalendarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CalendarButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _PaymentMethodSelector extends StatelessWidget {
  final PaymentType selectedPayment;
  final ValueChanged<PaymentType> onChanged;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController cardHolderController;

  const _PaymentMethodSelector({
    required this.selectedPayment,
    required this.onChanged,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.cardHolderController,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _PaymentOption(
        title: 'Credit Card',
        selected: selectedPayment == PaymentType.creditCard,
        onTap: () => onChanged(PaymentType.creditCard),
        child: selectedPayment == PaymentType.creditCard
            ? Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.science, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '🧪 Mock card — auto-filled for testing',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardHolderController,
                    decoration: InputDecoration(
                      hintText: 'Card holder name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: AppColors.paper,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cardNumberController,
                    decoration: InputDecoration(
                      hintText: 'Card number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: AppColors.paper,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expiryController,
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: AppColors.paper,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: AppColors.paper,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : null,
      ),
      const SizedBox(height: 10),
      _PaymentOption(
        title: 'Cash',
        subtitle: 'Pay on arrival',
        selected: selectedPayment == PaymentType.cash,
        onTap: () => onChanged(PaymentType.cash),
      ),
      const SizedBox(height: 10),
      _PaymentOption(
        title: 'Bonus Points',
        subtitle: 'Your balance: 150 points',
        selected: selectedPayment == PaymentType.bonuses,
        onTap: () => onChanged(PaymentType.bonuses),
      ),
    ],
  );
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  const _PaymentOption({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.ink3,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.ink3)),
                  ],
                ],
              ),
            ],
          ),
          if (child != null) child!,
        ],
      ),
    ),
  );
}
