// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'authorName': instance.authorName,
      'authorAvatarUrl': instance.authorAvatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };
