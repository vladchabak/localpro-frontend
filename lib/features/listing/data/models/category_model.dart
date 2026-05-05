import 'package:json_annotation/json_annotation.dart';
part 'category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  @JsonKey(defaultValue: [])
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
