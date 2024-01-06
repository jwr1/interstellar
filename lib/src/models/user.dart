import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/shared.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserListModel with _$UserListModel {
  const factory UserListModel({
    required List<DetailedUserModel> items,
    required PaginationModel pagination,
  }) = _UserListModel;

  factory UserListModel.fromJson(Map<String, Object?> json) =>
      _$UserListModelFromJson(json);
}

@freezed
class DetailedUserModel with _$DetailedUserModel {
  const factory DetailedUserModel({
    ImageModel? avatar,
    ImageModel? cover,
    required String username,
    required int followersCount,
    String? about,
    required DateTime createdAt,
    String? apProfileId,
    String? apId,
    required bool isBot,
    bool? isFollowedByUser,
    bool? isFollowerOfUser,
    bool? isBlockedByUser,
    required int userId,
  }) = _DetailedUserModel;

  factory DetailedUserModel.fromJson(Map<String, Object?> json) =>
      _$DetailedUserModelFromJson(json);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int userId,
    required String username,
    required bool isBot,
    bool? isFollowedByUser,
    bool? isFollowerOfUser,
    bool? isBlockedByUser,
    ImageModel? avatar,
    String? apId,
    String? apProfileId,
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) =>
      _$UserModelFromJson(json);
}
