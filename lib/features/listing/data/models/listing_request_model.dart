import 'package:json_annotation/json_annotation.dart';

part 'listing_request_model.g.dart';

enum PriceType {
  @JsonValue('PER_SERVICE')
  perService,
  @JsonValue('PER_HOUR')
  perHour,
  @JsonValue('NEGOTIABLE')
  negotiable,
}

@JsonSerializable()
class ListingRequest {
  final String title;
  final String description;
  final String categoryId;
  final double? price;
  final PriceType priceType;
  final double latitude;
  final double longitude;
  final List<String> photoUrls;
  final List<String> customQuestions;

  const ListingRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    this.price,
    required this.priceType,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
    required this.customQuestions,
  });

  factory ListingRequest.fromJson(Map<String, dynamic> json) =>
      _$ListingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ListingRequestToJson(this);
}
