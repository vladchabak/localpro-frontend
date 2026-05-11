import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/core_providers.dart';
import '../data/booking_api.dart';
import '../data/booking_repository.dart';
import '../data/models/booking_model.dart';

part 'booking_providers.g.dart';

@riverpod
BookingApi bookingApi(BookingApiRef ref) => BookingApi(ref.watch(dioProvider));

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) =>
    BookingRepository(ref.watch(bookingApiProvider));

@riverpod
Future<List<BookingResponse>> myBookings(MyBookingsRef ref) =>
    ref.watch(bookingRepositoryProvider).getMyBookings();

@riverpod
Future<BookingResponse> bookingDetail(BookingDetailRef ref, String id) =>
    ref.watch(bookingRepositoryProvider).getBooking(id);

@riverpod
Future<BookingResponse> createBooking(CreateBookingRef ref, BookingRequest request) =>
    ref.read(bookingRepositoryProvider).createBooking(request);

@riverpod
Future<BookingResponse> cancelBooking(CancelBookingRef ref, String id) =>
    ref.read(bookingRepositoryProvider).cancelBooking(id);
