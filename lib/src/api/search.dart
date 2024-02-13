import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/utils/utils.dart';

import '../models/entry.dart';
import '../models/magazine.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/user.dart';

class SearchList {
  const SearchList(this.items, this.pagination);

  final List<dynamic> items;
  final PaginationModel pagination;
}

Future<SearchList> search(
  http.Client client,
  String instanceHost, {
  int? page,
  String? search,
}) async {
  final response = await client.get(Uri.https(
    instanceHost,
    '/api/search',
    queryParams({'p': page?.toString(), 'q': search}),
  ));

  httpErrorHandler(response, message: 'Failed to load search');

  var json = jsonDecode(response.body) as Map<String, dynamic>;

  var searchList = SearchList([], PaginationModel.fromJson(json['pagination']));
  for (var actor in json['apActors']) {
    var type = actor['type'];
    if (type == 'user') {
      searchList.items.add(
          DetailedUserModel.fromJson(actor['object'] as Map<String, dynamic>));
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
