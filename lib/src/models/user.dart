import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/utils/models.dart';
import 'package:interstellar/src/widgets/markdown_mention.dart';

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
    required String? displayName,
    required String? avatar,
    required String? cover,
    required DateTime createdAt,
    required bool isBot,
    required String? about,
    required int? followersCount,
    required bool? isFollowedByUser,
    required bool? isFollowerOfUser,
    required bool? isBlockedByUser,
  }) = _DetailedUserModel;

  factory DetailedUserModel.fromKbin(Map<String, Object?> json) {
    final user = DetailedUserModel(
      id: json['userId'] as int,
      name: kbinNormalizeUsername(json['username'] as String),
      displayName: null,
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

    userMentionCache[user.name] = user;

    return user;
  }

  factory DetailedUserModel.fromLemmy(Map<String, Object?> json) {
    final lemmyPersonView = json['person_view'] as Map<String, Object?>;
    final lemmyPerson = lemmyPersonView['person'] as Map<String, Object?>;

    return DetailedUserModel(
      id: lemmyPerson['id'] as int,
      name: lemmyGetActorName(lemmyPerson),
      displayName: lemmyPerson['display_name'] as String?,
      avatar: lemmyPerson['avatar'] as String?,
      cover: lemmyPerson['banner'] as String?,
      createdAt: DateTime.parse(lemmyPerson['published'] as String),
      isBot: lemmyPerson['bot_account'] as bool,
      about: lemmyPerson['bio'] as String?,
      followersCount: null,
      isFollowedByUser: null,
      isFollowerOfUser: null,
      isBlockedByUser: (json['blocked'] as bool?) ?? false,
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
        name: kbinNormalizeUsername(json['username'] as String),
        avatar: kbinGetImageUrl(json['avatar'] as Map<String, Object?>?),
      );

  factory UserModel.fromLemmy(Map<String, Object?> json) => UserModel(
        id: json['id'] as int,
        name: lemmyGetActorName(json),
        avatar: json['avatar'] as String?,
      );
}

@unfreezed
class UserSettings with _$UserSettings {
  factory UserSettings({
    required bool showNSFW,
    required bool? blurNSFW,
    required bool? showReadPosts,

    required bool? showSubscribedUsers,
    required bool? showSubscribedMagazines,
    required bool? showSubscribedDomains,
    required bool? showProfileSubscriptions,
    required bool? showProfileFollowings,
  }) = _UserSettings;

  factory UserSettings.fromKbin(Map<String, Object?> json) => UserSettings(
    showNSFW: !(json['hideAdult'] as bool),
    blurNSFW: null,
    showReadPosts: null,
    showSubscribedUsers: json['showSubscribedUsers'] as bool?,
    showSubscribedMagazines: json['showSubscribedMagazines'] as bool?,
    showSubscribedDomains: json['showSubscribedDomains'] as bool?,
    showProfileSubscriptions: json['showProfileSubscriptions'] as bool?,
    showProfileFollowings: json['showProfileFollowings'] as bool?
  );

  factory UserSettings.fromLemmy(Map<String, Object?> json) => UserSettings(
    showNSFW: json['show_nsfw'] as bool,
    blurNSFW: json['blur_nsfw'] as bool?,
    showReadPosts: json['show_read_posts'] as bool?,
    showSubscribedUsers: null,
    showSubscribedMagazines: null,
    showSubscribedDomains: null,
    showProfileSubscriptions: null,
    showProfileFollowings: null
  );
}