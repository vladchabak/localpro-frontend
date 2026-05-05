import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role; // CLIENT, PROVIDER, BOTH
  final String? bio;
  final String? phone;
  final double rating;
  final int reviewCount;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.bio,
    this.phone,
    required this.rating,
    required this.reviewCount,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
