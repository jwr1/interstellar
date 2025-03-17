import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/utils/models.dart';
import 'package:interstellar/src/widgets/markdown/markdown_mention.dart';

part 'user.freezed.dart';

@freezed
class DetailedUserListModel with _$DetailedUserListModel {
  const factory DetailedUserListModel({
    required List<DetailedUserModel> items,
    required String? nextPage,
  }) = _DetailedUserListModel;

  factory DetailedUserListModel.fromMbin(Map<String, Object?> json) =>
      DetailedUserListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) =>
                DetailedUserModel.fromMbin(post as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );

  factory DetailedUserListModel.fromLemmy(Map<String, Object?> json) =>
      DetailedUserListModel(
        items: (json['users'] as List<dynamic>)
            .map((item) =>
                DetailedUserModel.fromLemmy(item as Map<String, Object?>))
            .toList(),
        nextPage: json['next_page'] as String?,
      );

  factory DetailedUserListModel.fromPiefed(Map<String, Object?> json) =>
      DetailedUserListModel(
        items: (json['users'] as List<dynamic>)
            .map((item) =>
                DetailedUserModel.fromPiefed(item as Map<String, Object?>))
            .toList(),
        nextPage: json['next_page'] as String?,
      );
}

@freezed
class DetailedUserModel with _$DetailedUserModel {
  const factory DetailedUserModel({
    required int id,
    required String name,
    required String? displayName,
    required ImageModel? avatar,
    required ImageModel? cover,
    required DateTime createdAt,
    required bool isBot,
    required String? about,
    required int? followersCount,
    required bool? isFollowedByUser,
    required bool? isFollowerOfUser,
    required bool? isBlockedByUser,
    required NotificationControlStatus? notificationControlStatus,
  }) = _DetailedUserModel;

  factory DetailedUserModel.fromMbin(Map<String, Object?> json) {
    final user = DetailedUserModel(
      id: json['userId'] as int,
      name: mbinNormalizeUsername(json['username'] as String),
      displayName: null,
      avatar: mbinGetOptionalImage(json['avatar'] as Map<String, Object?>?),
      cover: mbinGetOptionalImage(json['cover'] as Map<String, Object?>?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isBot: json['isBot'] as bool,
      about: json['about'] as String?,
      followersCount: json['followersCount'] as int,
      isFollowedByUser: json['isFollowedByUser'] as bool?,
      isFollowerOfUser: json['isFollowerOfUser'] as bool?,
      isBlockedByUser: json['isBlockedByUser'] as bool?,
      notificationControlStatus: json['notificationStatus'] == null
          ? null
          : NotificationControlStatus.fromJson(
              json['notificationStatus'] as String),
    );

    userMentionCache[user.name] = user;

    return user;
  }

  factory DetailedUserModel.fromLemmy(Map<String, Object?> json) {
    final lemmyPerson = json['person'] as Map<String, Object?>;

    return DetailedUserModel(
      id: lemmyPerson['id'] as int,
      name: getLemmyPiefedActorName(lemmyPerson),
      displayName: lemmyPerson['display_name'] as String?,
      avatar: lemmyGetOptionalImage(lemmyPerson['avatar'] as String?),
      cover: lemmyGetOptionalImage(lemmyPerson['banner'] as String?),
      createdAt: DateTime.parse(lemmyPerson['published'] as String),
      isBot: lemmyPerson['bot_account'] as bool,
      about: lemmyPerson['bio'] as String?,
      followersCount: null,
      isFollowedByUser: null,
      isFollowerOfUser: null,
      isBlockedByUser: (json['blocked'] as bool?) ?? false,
      notificationControlStatus: null,
    );
  }

  factory DetailedUserModel.fromPiefed(Map<String, Object?> json, {bool blocked = false}) {
    final piefedPerson = json['person'] as Map<String, Object?>;

    return DetailedUserModel(
      id: piefedPerson['id'] as int,
      name: getLemmyPiefedActorName(piefedPerson),
      displayName: piefedPerson['title'] as String?,
      avatar: null,
      cover: null,
      createdAt: DateTime.parse(piefedPerson['published'] as String),
      isBot: piefedPerson['bot'] as bool,
      about: piefedPerson['about'] as String?,
      followersCount: null,
      isFollowedByUser: null,
      isFollowerOfUser: null,
      isBlockedByUser: blocked,
      notificationControlStatus: null,
    );
  }
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
    required ImageModel? avatar,
    required DateTime? createdAt,
    required bool isBot,
  }) = _UserModel;

  factory UserModel.fromMbin(Map<String, Object?> json) => UserModel(
        id: json['userId'] as int,
        name: mbinNormalizeUsername(json['username'] as String),
        avatar: mbinGetOptionalImage(json['avatar'] as Map<String, Object?>?),
        createdAt: optionalDateTime(json['createdAt'] as String?),
        isBot: (json['isBot'] ?? false) as bool,
      );

  factory UserModel.fromLemmy(Map<String, Object?> json) => UserModel(
        id: json['id'] as int,
        name: getLemmyPiefedActorName(json),
        avatar: lemmyGetOptionalImage(json['avatar'] as String?),
        createdAt: DateTime.parse(json['published'] as String),
        isBot: json['bot_account'] as bool,
      );

  factory UserModel.fromPiefed(Map<String, Object?> json) => UserModel(
        id: json['id'] as int,
        name: getLemmyPiefedActorName(json),
        avatar: null,
        createdAt: DateTime.parse(json['published'] as String),
        isBot: json['bot'] as bool,
      );

  factory UserModel.fromDetailedUser(DetailedUserModel user) => UserModel(
        id: user.id,
        name: user.name,
        avatar: user.avatar,
        createdAt: user.createdAt,
        isBot: user.isBot,
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
    required bool? notifyOnNewEntry,
    required bool? notifyOnNewEntryReply,
    required bool? notifyOnNewEntryCommentReply,
    required bool? notifyOnNewPost,
    required bool? notifyOnNewPostReply,
    required bool? notifyOnNewPostCommentReply,
  }) = _UserSettings;

  factory UserSettings.fromMbin(Map<String, Object?> json) => UserSettings(
        showNSFW: !(json['hideAdult'] as bool),
        blurNSFW: null,
        showReadPosts: null,
        showSubscribedUsers: json['showSubscribedUsers'] as bool?,
        showSubscribedMagazines: json['showSubscribedMagazines'] as bool?,
        showSubscribedDomains: json['showSubscribedDomains'] as bool?,
        showProfileSubscriptions: json['showProfileSubscriptions'] as bool?,
        showProfileFollowings: json['showProfileFollowings'] as bool?,
        notifyOnNewEntry: json['notifyOnNewEntry'] as bool?,
        notifyOnNewEntryReply: json['notifyOnNewEntryReply'] as bool?,
        notifyOnNewEntryCommentReply:
            json['notifyOnNewEntryCommentReply'] as bool?,
        notifyOnNewPost: json['notifyOnNewPost'] as bool?,
        notifyOnNewPostReply: json['notifyOnNewPostReply'] as bool?,
        notifyOnNewPostCommentReply:
            json['notifyOnNewPostCommentReply'] as bool?,
      );

  factory UserSettings.fromLemmy(Map<String, Object?> json) => UserSettings(
        showNSFW: json['show_nsfw'] as bool,
        blurNSFW: json['blur_nsfw'] as bool?,
        showReadPosts: json['show_read_posts'] as bool?,
        showSubscribedUsers: null,
        showSubscribedMagazines: null,
        showSubscribedDomains: null,
        showProfileSubscriptions: null,
        showProfileFollowings: null,
        notifyOnNewEntry: null,
        notifyOnNewEntryReply: null,
        notifyOnNewEntryCommentReply: null,
        notifyOnNewPost: null,
        notifyOnNewPostReply: null,
        notifyOnNewPostCommentReply: null,
      );

  factory UserSettings.fromPiefed(Map<String, Object?> json) => UserSettings(
        showNSFW: json['show_nsfw'] as bool,
        blurNSFW: null,
        showReadPosts: json['show_read_posts'] as bool?,
        showSubscribedUsers: null,
        showSubscribedMagazines: null,
        showSubscribedDomains: null,
        showProfileSubscriptions: null,
        showProfileFollowings: null,
        notifyOnNewEntry: null,
        notifyOnNewEntryReply: null,
        notifyOnNewEntryCommentReply: null,
        notifyOnNewPost: null,
        notifyOnNewPostReply: null,
        notifyOnNewPostCommentReply: null,
      );
}
