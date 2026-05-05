// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingDetailModel _$ListingDetailModelFromJson(Map<String, dynamic> json) =>
    ListingDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerAvatarUrl: json['providerAvatarUrl'] as String?,
      providerRating: (json['providerRating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      price: (json['price'] as num?)?.toDouble(),
      priceType: json['priceType'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      status: json['status'] as String,
      viewCount: (json['viewCount'] as num).toInt(),
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ListingDetailModelToJson(ListingDetailModel instance) =>
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
      'reviewCount': instance.reviewCount,
      'price': instance.price,
      'priceType': instance.priceType,
      'address': instance.address,
      'city': instance.city,
      'status': instance.status,
      'viewCount': instance.viewCount,
      'photoUrls': instance.photoUrls,
      'rating': instance.rating,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
