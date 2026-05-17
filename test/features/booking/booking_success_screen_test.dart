import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localpro_mobile/features/booking/data/models/booking_model.dart';
import 'package:localpro_mobile/features/booking/domain/booking_providers.dart';
import 'package:localpro_mobile/features/booking/presentation/booking_success_screen.dart';

final fakeBooking = BookingResponse(
  id: 'b-1-booking-id-12345',
  status: BookingStatus.pending,
  scheduledAt: DateTime(2026, 6, 15, 14, 30),
  totalPrice: 50.0,
  listingId: 'listing-1',
  listingTitle: 'Test Plumbing',
  providerId: 'prov-1',
  providerName: 'Alice',
  createdAt: DateTime.now(),
);

void main() {
  group('BookingSuccessScreen', () {
    testWidgets('shows booking details when loaded', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/booking/success/:id',
            builder: (context, state) => BookingSuccessScreen(
              bookingId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Map Screen')),
            ),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Bookings Screen')),
            ),
          ),
        ],
        initialLocation: '/booking/success/b-1-booking-id-12345',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingDetailProvider('b-1-booking-id-12345').overrideWith(
              (ref) => fakeBooking,
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('Test Plumbing'), findsOneWidget);
      expect(find.text('€50.00'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });
  });
}
