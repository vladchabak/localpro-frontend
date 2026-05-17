import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
