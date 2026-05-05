// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_listing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearbyListingModel _$NearbyListingModelFromJson(Map<String, dynamic> json) =>
    NearbyListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerAvatarUrl: json['providerAvatarUrl'] as String?,
      providerRating: (json['providerRating'] as num).toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      priceType: json['priceType'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      status: json['status'] as String?,
      viewCount: (json['viewCount'] as num).toInt(),
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      distanceLabel: json['distanceLabel'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NearbyListingModelToJson(NearbyListingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'providerAvatarUrl': instance.providerAvatarUrl,
      'providerRating': instance.providerRating,
      'price': instance.price,
      'priceType': instance.priceType,
      'address': instance.address,
      'city': instance.city,
      'status': instance.status,
      'viewCount': instance.viewCount,
      'photoUrls': instance.photoUrls,
      'distanceMeters': instance.distanceMeters,
      'distanceLabel': instance.distanceLabel,
      'lat': instance.lat,
      'lng': instance.lng,
    };
