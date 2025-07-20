import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

/// Model representing a user's profile data.
@JsonSerializable()
class UserProfileModel {
  final String uid;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
  });

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  /// Creates a [UserProfileModel] from a JSON map.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
}