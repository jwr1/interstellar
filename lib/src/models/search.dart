import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/models.dart';

part 'search.freezed.dart';

@freezed
class SearchListModel with _$SearchListModel {
  const factory SearchListModel({
    required List<Object> items,
    required String? nextPage,
  }) = _SearchListModel;

  factory SearchListModel.fromMbin(Map<String, dynamic> json) {
    List<Object> items = [];

    for (var actor in json['apActors']) {
      var type = actor['type'];
      if (type == 'user') {
        items.add(DetailedUserModel.fromMbin(
            actor['object'] as Map<String, Object?>));
      } else if (type == 'magazine') {
        items.add(DetailedMagazineModel.fromMbin(
            actor['object'] as Map<String, Object?>));
      }
    }
    for (var item in json['items']) {
      var itemType = item['itemType'];
      if (itemType == 'entry') {
        items.add(PostModel.fromMbinEntry(item as Map<String, Object?>));
      } else if (itemType == 'post') {
        items.add(PostModel.fromMbinPost(item as Map<String, Object?>));
      } else if (itemType == 'entry_comment' || itemType == 'post_comment') {
        items.add(CommentModel.fromMbin(item as Map<String, Object?>));
      }
    }

    return SearchListModel(
      items: items,
      nextPage: mbinCalcNextPaginationPage(
          json['pagination'] as Map<String, Object?>),
    );
  }

  factory SearchListModel.fromLemmy(Map<String, dynamic> json) {
    List<Object> items = [];

    for (var user in json['users']) {
      items.add(DetailedUserModel.fromLemmy(user));
    }

    for (var community in json['communities']) {
      items.add(
          DetailedMagazineModel.fromLemmy(community as Map<String, Object?>));
    }

    for (var post in json['posts']) {
      items.add(PostModel.fromLemmy(post as Map<String, Object?>));
    }

    for (var comment in json['comments']) {
      items.add(CommentModel.fromLemmy(comment as Map<String, Object?>));
    }

    return SearchListModel(
        items: items, nextPage: json['next_page'] as String?);
  }

  factory SearchListModel.fromPiefed(Map<String, dynamic> json) {
    List<Object> items = [];

    for (var user in json['users']) {
      items.add(DetailedUserModel.fromPiefed(user));
    }

    for (var community in json['communities']) {
      items.add(
          DetailedMagazineModel.fromPiefed(community as Map<String, Object?>));
    }

    for (var post in json['posts']) {
      items.add(PostModel.fromPiefed(post as Map<String, Object?>));
    }

    for (var comment in json['comments']) {
      items.add(CommentModel.fromPiefed(comment as Map<String, Object?>));
    }

    return SearchListModel(
        items: items, nextPage: json['next_page'] as String?);
  }
}
