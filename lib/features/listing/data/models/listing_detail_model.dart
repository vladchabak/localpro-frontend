import 'package:json_annotation/json_annotation.dart';
import 'listing_request_model.dart';

part 'listing_detail_model.g.dart';

@JsonSerializable()
class ListingDetailModel {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final String categoryName;
  final String providerId;
  final String providerName;
  final String? providerAvatarUrl;
  final double providerRating;
  final int reviewCount;
  final double? price;
  final PriceType priceType;
  final String? address;
  final String? city;
  final String status;
  final int viewCount;
  final List<String> photoUrls;
  final double? rating;
  final DateTime? createdAt;
  final bool isVerified;
  final DateTime? verifiedAt;
  final List<String> customQuestions;
  final bool isVisibleOnMap;

  const ListingDetailModel({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.categoryName,
    required this.providerId,
    required this.providerName,
    this.providerAvatarUrl,
    required this.providerRating,
    required this.reviewCount,
    this.price,
    required this.priceType,
    this.address,
    this.city,
    required this.status,
    required this.viewCount,
    required this.photoUrls,
    this.rating,
    this.createdAt,
    required this.isVerified,
    this.verifiedAt,
    required this.customQuestions,
    required this.isVisibleOnMap,
  });

  factory ListingDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ListingDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$ListingDetailModelToJson(this);
}
