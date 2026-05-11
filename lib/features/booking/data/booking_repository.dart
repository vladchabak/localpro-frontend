import 'models/booking_model.dart';
import 'booking_api.dart';

class BookingRepository {
  final BookingApi _api;
  BookingRepository(this._api);

  Future<BookingResponse> createBooking(BookingRequest request) => _api.createBooking(request);

  Future<List<BookingResponse>> getMyBookings({int page = 0, int size = 20}) async {
    final response = await _api.getMyBookings(page: page, size: size);
    return response.content;
  }

  Future<BookingResponse> cancelBooking(String id) => _api.cancelBooking(id);

  Future<BookingResponse> getBooking(String id) => _api.getBooking(id);
}
