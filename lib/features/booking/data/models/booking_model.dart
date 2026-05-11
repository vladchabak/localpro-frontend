import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

enum PaymentType { @JsonValue('CREDIT_CARD') creditCard, @JsonValue('CASH') cash, @JsonValue('BONUSES') bonuses }

enum CalendarType { @JsonValue('CALENDLY') calendly, @JsonValue('GOOGLE_CALENDAR') googleCalendar, @JsonValue('IN_APP') inApp }

enum BookingStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('CONFIRMED') confirmed,
  @JsonValue('CANCELLED') cancelled,
  @JsonValue('COMPLETED') completed;

  String get label => switch (this) {
    BookingStatus.pending => 'PENDING',
    BookingStatus.confirmed => 'CONFIRMED',
    BookingStatus.cancelled => 'CANCELLED',
    BookingStatus.completed => 'COMPLETED',
  };
}

enum PaymentStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('PAID') paid,
  @JsonValue('FAILED') failed,
  @JsonValue('REFUNDED') refunded;
}

@JsonSerializable()
class BookingRequest {
  final String listingId;
  final DateTime scheduledAt;
  final PaymentType paymentType;
  final CalendarType calendarType;
  final String? notes;

  const BookingRequest({
    required this.listingId,
    required this.scheduledAt,
    required this.paymentType,
    required this.calendarType,
    this.notes,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) => _$BookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookingRequestToJson(this);
}

@JsonSerializable()
class BookingResponse {
  final String id;
  final BookingStatus status;
  final PaymentStatus? paymentStatus;
  final DateTime scheduledAt;
  final String? calendlyUrl;
  final String? googleCalendarUrl;
  final double totalPrice;
  final String listingId;
  final String listingTitle;
  final String providerId;
  final String providerName;
  final DateTime createdAt;

  const BookingResponse({
    required this.id,
    required this.status,
    this.paymentStatus,
    required this.scheduledAt,
    this.calendlyUrl,
    this.googleCalendarUrl,
    required this.totalPrice,
    required this.listingId,
    required this.listingTitle,
    required this.providerId,
    required this.providerName,
    required this.createdAt,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) => _$BookingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BookingResponseToJson(this);
}
