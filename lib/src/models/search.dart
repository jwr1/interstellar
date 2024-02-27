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

  factory SearchListModel.fromKbin(Map<String, dynamic> json) {
    List<Object> items = [];

    for (var actor in json['apActors']) {
      var type = actor['type'];
      if (type == 'user') {
        items.add(DetailedUserModel.fromKbin(
            actor['object'] as Map<String, Object?>));
      } else if (type == 'magazine') {
        items.add(DetailedMagazineModel.fromKbin(
            actor['object'] as Map<String, Object?>));
      }
    }
    for (var item in json['items']) {
      var itemType = item['itemType'];
      if (itemType == 'entry') {
        items.add(PostModel.fromKbinEntry(item as Map<String, Object?>));
      } else if (itemType == 'post') {
        items.add(PostModel.fromKbinPost(item as Map<String, Object?>));
      } else if (itemType == 'entry_comment' || itemType == 'post_comment') {
        items.add(CommentModel.fromKbin(item as Map<String, Object?>));
      }
    }

    return SearchListModel(
      items: items,
      nextPage: kbinCalcNextPaginationPage(
          json['pagination'] as Map<String, Object?>),
    );
  }

  factory SearchListModel.fromLemmy(Map<String, dynamic> json) {
    List<Object> items = [];

    for (var actor in json['users']) {
      items.add(DetailedUserModel.fromLemmy({'person_view': actor}));
    }

    for (var community in json['communities']) {
      items.add(DetailedMagazineModel.fromLemmy(community as Map<String, Object?>));
    }

    for (var post in json['posts']) {
      items.add(PostModel.fromLemmy(post as Map<String, Object?>));
    }

    for (var comment in json['comments']) {
      items.add(CommentModel.fromLemmy(comment as Map<String, Object?>));
    }

    return SearchListModel(
      items: items,
      nextPage: json['next_page'] as String?
    );
  }
}
