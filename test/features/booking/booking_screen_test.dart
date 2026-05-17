import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localpro_mobile/features/booking/data/booking_repository.dart';
import 'package:localpro_mobile/features/booking/data/models/booking_model.dart';
import 'package:localpro_mobile/features/booking/domain/booking_providers.dart';
import 'package:localpro_mobile/features/booking/presentation/booking_screen.dart';
import 'package:localpro_mobile/features/listing/data/models/listing_detail_model.dart';
import 'package:localpro_mobile/features/listing/data/models/listing_request_model.dart';
import 'package:mocktail/mocktail.dart';

final fakeListing = ListingDetailModel(
  id: 'listing-1',
  title: 'Test Plumbing',
  description: 'Test plumbing services',
  categoryId: 'cat-1',
  categoryName: 'Plumbing',
  providerId: 'prov-1',
  providerName: 'Alice',
  providerRating: 4.5,
  reviewCount: 10,
  price: 50.0,
  priceType: PriceType.perHour,
  address: '123 Main St',
  city: 'Berlin',
  status: 'active',
  viewCount: 100,
  photoUrls: [],
  isVerified: true,
  customQuestions: [],
  isVisibleOnMap: true,
);

final fakeBookingResponse = BookingResponse(
  id: 'booking-123',
  status: BookingStatus.pending,
  scheduledAt: DateTime.now().add(const Duration(days: 1)),
  totalPrice: 50.0,
  listingId: 'listing-1',
  listingTitle: 'Test Plumbing',
  providerId: 'prov-1',
  providerName: 'Alice',
  createdAt: DateTime.now(),
);

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  registerFallbackValue(BookingRequest(
    listingId: '',
    scheduledAt: DateTime.now(),
    paymentType: PaymentType.creditCard,
    calendarType: CalendarType.inApp,
  ));

  group('BookingScreen', () {
    testWidgets('renders listing info card', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: BookingScreen(listing: fakeListing),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Plumbing'), findsOneWidget);
      expect(find.text('€50.00/hr'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders confirm booking button', (WidgetTester tester) async {
      final mockRepo = MockBookingRepository();
      when(() => mockRepo.createBooking(any())).thenAnswer((_) async => fakeBookingResponse);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: BookingScreen(listing: fakeListing),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Confirm Booking'), findsOneWidget);
    });

    testWidgets('shows error SnackBar on API failure', (WidgetTester tester) async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/bookings'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/bookings'),
          data: {'message': 'Slot taken'},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );

      final mockRepo = MockBookingRepository();
      when(() => mockRepo.createBooking(any())).thenThrow(dioException);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: BookingScreen(listing: fakeListing),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      final confirmButton = find.text('Confirm Booking');
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.text('Booking failed: Slot taken'), findsOneWidget);
    });
  });
}
