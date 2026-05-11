// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingRequest _$ListingRequestFromJson(Map<String, dynamic> json) =>
    ListingRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num?)?.toDouble(),
      priceType: $enumDecode(_$PriceTypeEnumMap, json['priceType']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      customQuestions: (json['customQuestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ListingRequestToJson(ListingRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'price': instance.price,
      'priceType': _$PriceTypeEnumMap[instance.priceType]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photoUrls': instance.photoUrls,
      'customQuestions': instance.customQuestions,
    };

const _$PriceTypeEnumMap = {
  PriceType.perService: 'PER_SERVICE',
  PriceType.perHour: 'PER_HOUR',
  PriceType.negotiable: 'NEGOTIABLE',
};
