import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/old/magazine.dart';
import 'package:interstellar/src/models/old/shared.dart';
import 'package:interstellar/src/models/old/user.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/utils/utils.dart';

class SearchList {
  const SearchList(this.items, this.pagination);

  final List<dynamic> items;
  final PaginationModel pagination;
}

class KbinAPISearch {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPISearch(
    this.httpClient,
    this.instanceHost,
  );

  Future<SearchList> get({
    int? page,
    String? search,
  }) async {
    const path = '/api/search';

    final response = await httpClient.get(Uri.https(
      instanceHost,
      path,
      queryParams({'p': page?.toString(), 'q': search}),
    ));

    httpErrorHandler(response, message: 'Failed to load search');

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    var searchList =
        SearchList([], PaginationModel.fromJson(json['pagination']));
    for (var actor in json['apActors']) {
      var type = actor['type'];
      if (type == 'user') {
        searchList.items.add(DetailedUserModel.fromJson(
            actor['object'] as Map<String, Object?>));
      } else if (type == 'magazine') {
        searchList.items.add(DetailedMagazineModel.fromJson(
            actor['object'] as Map<String, Object?>));
      }
    }
    for (var item in json['items']) {
      var itemType = item['itemType'];
      if (itemType == 'entry') {
        searchList.items
            .add(PostModel.fromKbinEntry(item as Map<String, Object?>));
      } else if (itemType == 'post') {
        searchList.items
            .add(PostModel.fromKbinPost(item as Map<String, Object?>));
      } else if (itemType == 'entry_comment' || itemType == 'post_comment') {
        searchList.items
            .add(CommentModel.fromKbin(item as Map<String, Object?>));
      }
    }

    return searchList;
  }
}
