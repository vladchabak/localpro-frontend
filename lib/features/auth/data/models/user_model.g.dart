// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'firebaseUid': instance.firebaseUid,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'role': instance.role,
      'bio': instance.bio,
      'phone': instance.phone,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isActive': instance.isActive,
    };
