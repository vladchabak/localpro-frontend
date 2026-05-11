import 'package:dio/dio.dart';
import '../../../core/models/page_response.dart';
import 'models/booking_model.dart';

class BookingApi {
  final Dio _dio;
  BookingApi(this._dio);

  Future<BookingResponse> createBooking(BookingRequest request) async {
    final response = await _dio.post('/api/bookings', data: request.toJson());
    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PageResponse<BookingResponse>> getMyBookings({int page = 0, int size = 20}) async {
    final response = await _dio.get('/api/bookings/my', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => BookingResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BookingResponse> cancelBooking(String id) async {
    final response = await _dio.put('/api/bookings/$id/cancel');
    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingResponse> getBooking(String id) async {
    final response = await _dio.get('/api/bookings/$id');
    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
