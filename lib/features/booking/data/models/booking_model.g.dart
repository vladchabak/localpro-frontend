// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingRequest _$BookingRequestFromJson(Map<String, dynamic> json) =>
    BookingRequest(
      listingId: json['listingId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      paymentType: $enumDecode(_$PaymentTypeEnumMap, json['paymentType']),
      calendarType: $enumDecode(_$CalendarTypeEnumMap, json['calendarType']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookingRequestToJson(BookingRequest instance) =>
    <String, dynamic>{
      'listingId': instance.listingId,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'paymentType': _$PaymentTypeEnumMap[instance.paymentType]!,
      'calendarType': _$CalendarTypeEnumMap[instance.calendarType]!,
      'notes': instance.notes,
    };

const _$PaymentTypeEnumMap = {
  PaymentType.creditCard: 'CREDIT_CARD',
  PaymentType.cash: 'CASH',
  PaymentType.bonuses: 'BONUSES',
};

const _$CalendarTypeEnumMap = {
  CalendarType.calendly: 'CALENDLY',
  CalendarType.googleCalendar: 'GOOGLE_CALENDAR',
  CalendarType.inApp: 'IN_APP',
};

BookingResponse _$BookingResponseFromJson(Map<String, dynamic> json) =>
    BookingResponse(
      id: json['id'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      paymentStatus: $enumDecodeNullable(_$PaymentStatusEnumMap, json['paymentStatus']),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      calendlyUrl: json['calendlyUrl'] as String?,
      googleCalendarUrl: json['googleCalendarUrl'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      listingId: json['listingId'] as String,
      listingTitle: json['listingTitle'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookingResponseToJson(BookingResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus],
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'calendlyUrl': instance.calendlyUrl,
      'googleCalendarUrl': instance.googleCalendarUrl,
      'totalPrice': instance.totalPrice,
      'listingId': instance.listingId,
      'listingTitle': instance.listingTitle,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'PENDING',
  BookingStatus.confirmed: 'CONFIRMED',
  BookingStatus.cancelled: 'CANCELLED',
  BookingStatus.completed: 'COMPLETED',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'PENDING',
  PaymentStatus.paid: 'PAID',
  PaymentStatus.failed: 'FAILED',
  PaymentStatus.refunded: 'REFUNDED',
};
