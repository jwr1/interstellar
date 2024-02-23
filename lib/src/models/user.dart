import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/utils/models.dart';

part 'user.freezed.dart';

@freezed
class DetailedUserListModel with _$DetailedUserListModel {
  const factory DetailedUserListModel({
    required List<DetailedUserModel> items,
    required String? nextPage,
  }) = _DetailedUserListModel;

  factory DetailedUserListModel.fromKbin(Map<String, Object?> json) =>
      DetailedUserListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) =>
                DetailedUserModel.fromKbin(post as Map<String, Object?>))
            .toList(),
        nextPage: kbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );
}

@freezed
class DetailedUserModel with _$DetailedUserModel {
  const factory DetailedUserModel({
    required int id,
    required String name,
    required String? avatar,
    required String? cover,
    required DateTime createdAt,
    required bool isBot,
    required String? about,
    required int followersCount,
    required bool? isFollowedByUser,
    required bool? isFollowerOfUser,
    required bool? isBlockedByUser,
  }) = _DetailedUserModel;

  factory DetailedUserModel.fromKbin(Map<String, Object?> json) =>
      DetailedUserModel(
        id: json['userId'] as int,
        name: json['username'] as String,
        avatar: kbinGetImageUrl(json['avatar'] as Map<String, Object?>?),
        cover: kbinGetImageUrl(json['cover'] as Map<String, Object?>?),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isBot: json['isBot'] as bool,
        about: json['about'] as String?,
        followersCount: json['followersCount'] as int,
        isFollowedByUser: json['isFollowedByUser'] as bool?,
        isFollowerOfUser: json['isFollowerOfUser'] as bool?,
        isBlockedByUser: json['isBlockedByUser'] as bool?,
      );

  factory DetailedUserModel.fromLemmy(Map<String, Object?> json) {
    final lemmyPersonView = json['person_view'] as Map<String, Object?>;
    final lemmyPerson = lemmyPersonView['person'] as Map<String, Object?>;

    return DetailedUserModel(
        id: lemmyPerson['id'] as int,
        name: lemmyPerson['name'] as String,
        avatar: lemmyPerson['avatar'] as String?,
        cover: lemmyPerson['banner'] as String?,
        createdAt: DateTime.parse(lemmyPerson['published'] as String),
        isBot: lemmyPerson['bot_account'] as bool,
        about: lemmyPerson['bio'] as String?,
        followersCount: 0,
        isFollowedByUser: null,
        isFollowerOfUser: null,
        isBlockedByUser: lemmyPerson['banned'] as bool
    );
  }
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
    required String? avatar,
  }) = _UserModel;

  factory UserModel.fromKbin(Map<String, Object?> json) => UserModel(
        id: json['userId'] as int,
        name: json['username'] as String,
        avatar: kbinGetImageUrl(json['avatar'] as Map<String, Object?>?),
      );

  factory UserModel.fromLemmy(Map<String, Object?> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
      );
}
