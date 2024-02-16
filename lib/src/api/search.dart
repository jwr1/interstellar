import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/entry.dart';
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/models/user.dart';
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

    var json = jsonDecode(response.body) as Map<String, dynamic>;

    var searchList =
        SearchList([], PaginationModel.fromJson(json['pagination']));
    for (var actor in json['apActors']) {
      var type = actor['type'];
      if (type == 'user') {
        searchList.items.add(DetailedUserModel.fromJson(
            actor['object'] as Map<String, dynamic>));
      } else if (type == 'magazine') {
        searchList.items.add(DetailedMagazineModel.fromJson(
            actor['object'] as Map<String, dynamic>));
      }
    }
    for (var item in json['items']) {
      var itemType = item['itemType'];
      if (itemType == 'entry') {
        searchList.items.add(EntryModel.fromJson(item as Map<String, dynamic>));
      } else if (itemType == 'entry_comment') {
        searchList.items
            .add(EntryCommentModel.fromJson(item as Map<String, dynamic>));
      } else if (itemType == 'post') {
        searchList.items.add(PostModel.fromJson(item as Map<String, dynamic>));
      } else if (itemType == 'post_comment') {
        searchList.items
            .add(PostCommentModel.fromJson(item as Map<String, dynamic>));
      }
    }

    return searchList;
  }
}
