import 'package:json_annotation/json_annotation.dart';
part 'nearby_listing_model.g.dart';

@JsonSerializable()
class NearbyListingModel {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final String categoryName;
  final String providerId;
  final String providerName;
  final String? providerAvatarUrl;
  final double providerRating;
  final double? price;
  final String priceType;
  final String? address;
  final String? city;
  final String? status;
  final int viewCount;
  final List<String> photoUrls;
  final double distanceMeters;
  final String distanceLabel;
  final double? lat;
  final double? lng;

  const NearbyListingModel({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.categoryName,
    required this.providerId,
    required this.providerName,
    this.providerAvatarUrl,
    required this.providerRating,
    this.price,
    required this.priceType,
    this.address,
    this.city,
    this.status,
    required this.viewCount,
    required this.photoUrls,
    required this.distanceMeters,
    required this.distanceLabel,
    this.lat,
    this.lng,
  });

  factory NearbyListingModel.fromJson(Map<String, dynamic> json) =>
      _$NearbyListingModelFromJson(json);
  Map<String, dynamic> toJson() => _$NearbyListingModelToJson(this);
}
