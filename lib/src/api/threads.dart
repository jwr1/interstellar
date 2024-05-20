import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/models.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

const Map<FeedSort, String> lemmyFeedSortMap = {
  FeedSort.active: 'Active',
  FeedSort.hot: 'Hot',
  FeedSort.newest: 'New',
  FeedSort.oldest: 'Old',
  FeedSort.top: 'TopAll',
  FeedSort.commented: 'MostComments',
  FeedSort.topDay: 'TopDay',
  FeedSort.topWeek: 'TopWeek',
  FeedSort.topMonth: 'TopMonth',
  FeedSort.topYear: 'TopYear',
  FeedSort.newComments: 'NewComments',
  FeedSort.topHour: 'TopHour',
  FeedSort.topSixHour: 'TopSixHour',
  FeedSort.topTwelveHour: 'TopTwelveHour',
  FeedSort.topThreeMonths: 'TopThreeMonths',
  FeedSort.topSixMonths: 'TopSixMonths',
  FeedSort.topNineMonths: 'TopNineMonths',
  FeedSort.controversial: 'Controversial',
  FeedSort.scaled: 'Scaled',
};

class APIThreads {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIThreads(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<PostListModel> list(
    FeedSource source, {
    int? sourceId,
    String? page,
    FeedSort? sort,
    List<String>? langs,
    bool? usePreferredLangs,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = switch (source) {
          FeedSource.all => '/api/entries',
          FeedSource.subscribed => '/api/entries/subscribed',
          FeedSource.moderated => '/api/entries/moderated',
          FeedSource.favorited => '/api/entries/favourited',
          FeedSource.magazine => '/api/magazine/${sourceId!}/entries',
          FeedSource.user => '/api/users/${sourceId!}/entries',
          FeedSource.domain => '/api/domain/${sourceId!}/entries',
        };
        final query = queryParams({
          'p': page,
          'sort': sort?.name,
          'lang': langs?.join(','),
          'usePreferredLangs': (usePreferredLangs ?? false).toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load entries');

        return PostListModel.fromKbinEntries(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        if (source == FeedSource.user) {
          const path = '/api/v3/user';
          final query = queryParams({
            'person_id': sourceId.toString(),
            'page': page,
            'sort': lemmyFeedSortMap[sort]
          });

          final response = await httpClient.get(Uri.https(server, path, query));

          httpErrorHandler(response, message: "Failed to load user");

          final json = jsonDecode(response.body) as Map<String, Object?>;

          json['next_page'] =
              lemmyCalcNextIntPage(json['posts'] as List<dynamic>, page);

          return PostListModel.fromLemmy(json);
        }

        const path = '/api/v3/post/list';
        final query = queryParams({
          'page_cursor': page,
          'sort': lemmyFeedSortMap[sort],
        }..addAll(switch (source) {
            FeedSource.all => {'type_': 'All'},
            FeedSource.subscribed => {'type_': 'Subscribed'},
            FeedSource.moderated => {'type_': 'ModeratorView'},
            FeedSource.favorited => {'liked_only': 'true'},
            FeedSource.magazine => {'community_id': sourceId!.toString()},
            FeedSource.user =>
              throw Exception('User source not allowed for lemmy'),
            FeedSource.domain =>
              throw Exception('Domain source not allowed for lemmy'),
          }));

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load posts');

        return PostListModel.fromLemmy(
            jsonDecode(response.body) as Map<String, Object?>);
    }
  }

  Future<PostModel> get(int postId) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/entry/$postId';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load post');

        return PostModel.fromKbinEntry(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/post';
        final query = queryParams({
          'id': postId.toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load post');

        return PostModel.fromLemmy(
            jsonDecode(response.body)['post_view'] as Map<String, Object?>);
    }
  }

  Future<PostModel> vote(int postId, int choice, int newScore) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = choice == 1
            ? '/api/entry/$postId/favourite'
            : '/api/entry/$postId/vote/$choice';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send vote');

        return PostModel.fromKbinEntry(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/post/like';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'post_id': postId,
            'score': newScore,
          }),
        );

        httpErrorHandler(response, message: 'Failed to send vote');

        return PostModel.fromLemmy(
            jsonDecode(response.body)['post_view'] as Map<String, Object?>);
    }
  }

  Future<PostModel> boost(int postId) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/entry/$postId/vote/1';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send boost');

        return PostModel.fromKbinEntry(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Tried to boost on lemmy');
    }
  }

  Future<PostModel> edit(
    int entryID,
    String title,
    bool isOc,
    String body,
    String lang,
    bool isAdult,
  ) async {
    final path = '/api/entry/$entryID';

    final response = await httpClient.put(
      Uri.https(server, path),
      body: jsonEncode({
        'title': title,
        'tags': [],
        'isOc': isOc,
        'body': body,
        'lang': lang,
        'isAdult': isAdult
      }),
    );

    httpErrorHandler(response, message: "Failed to edit entry");

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<void> delete(int postID) async {
    final response =
        await httpClient.delete(Uri.https(server, '/api/entry/$postID'));

    httpErrorHandler(response, message: "Failed to delete entry");
  }

  Future<PostModel> createArticle(
    int magazineID, {
    required String title,
    required bool isOc,
    required String body,
    required String lang,
    required bool isAdult,
    required List<String> tags,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/magazine/$magazineID/article';

        final response = await httpClient.post(
          Uri.https(server, path),
          body: jsonEncode({
            'title': title,
            'tags': tags,
            'isOc': isOc,
            'body': body,
            'lang': lang,
            'isAdult': isAdult
          }),
        );

        httpErrorHandler(response, message: "Failed to create entry");

        return PostModel.fromKbinEntry(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/post';
        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': title,
            'community_id': magazineID,
            'body': body,
            'nsfw': isAdult
          }),
        );

        httpErrorHandler(response, message: 'Failed to create entry');

        return PostModel.fromLemmy(
            jsonDecode(response.body)['post_view'] as Map<String, Object?>);
    }
  }

  Future<PostModel> createLink(
    int magazineID, {
    required String title,
    required String url,
    required bool isOc,
    required String body,
    required String lang,
    required bool isAdult,
    required List<String> tags,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/magazine/$magazineID/link';

        final response = await httpClient.post(
          Uri.https(server, path),
          body: jsonEncode({
            'title': title,
            'url': url,
            'tags': tags,
            'isOc': isOc,
            'body': body,
            'lang': lang,
            'isAdult': isAdult
          }),
        );

        httpErrorHandler(response, message: "Failed to create entry");

        return PostModel.fromKbinEntry(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/post';
        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': title,
            'community_id': magazineID,
            'url': url,
            'body': body,
            'nsfw': isAdult
          }),
        );

        httpErrorHandler(response, message: 'Failed to create entry');

        return PostModel.fromLemmy(
            jsonDecode(response.body)['post_view'] as Map<String, Object?>);
    }
  }

  Future<PostModel> createImage(
    int magazineID, {
    required String title,
    required XFile image,
    required String alt,
    required bool isOc,
    required String body,
    required String lang,
    required bool isAdult,
    required List<String> tags,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/magazine/$magazineID/image';

        var request = http.MultipartRequest('POST', Uri.https(server, path));
        var multipartFile = http.MultipartFile.fromBytes(
          'uploadImage',
          await image.readAsBytes(),
          filename: basename(image.path),
          contentType: MediaType.parse(lookupMimeType(image.path)!),
        );
        request.files.add(multipartFile);
        request.fields['title'] = title;
        for (int i = 0; i < tags.length; i++) {
          request.fields['tags[$i]'] = tags[i];
        }
        request.fields['isOc'] = isOc.toString();
        request.fields['body'] = body;
        request.fields['lang'] = lang;
        request.fields['isAdult'] = isAdult.toString();
        request.fields['alt'] = alt;
        var response =
            await http.Response.fromStream(await httpClient.send(request));

        httpErrorHandler(response, message: "Failed to create entry");

        return PostModel.fromKbinEntry(
            jsonDecode(response.body) as Map<String, Object?>);
      case ServerSoftware.lemmy:
        const pictrsPath = '/pictrs/image';

        var request =
            http.MultipartRequest('POST', Uri.https(server, pictrsPath));
        var multipartFile = http.MultipartFile.fromBytes(
          'images[]',
          await image.readAsBytes(),
          filename: basename(image.path),
          contentType: MediaType.parse(lookupMimeType(image.path)!),
        );
        request.files.add(multipartFile);
        var pictrsResponse =
            await http.Response.fromStream(await httpClient.send(request));

        httpErrorHandler(pictrsResponse, message: "Failed to upload image");

        final json = jsonDecode(pictrsResponse.body) as Map<String, Object?>;

        final imageName = ((json['files'] as List<Object?>).first
            as Map<String, Object?>)['file'] as String?;

        const path = '/api/v3/post';
        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': title,
            'community_id': magazineID,
            'url': 'https://$server/pictrs/image/$imageName',
            'body': body,
            'nsfw': isAdult
          }),
        );

        httpErrorHandler(response, message: 'Failed to create entry');

        return PostModel.fromLemmy(
            jsonDecode(response.body)['post_view'] as Map<String, Object?>);
    }
  }

  Future<void> report(int postId, String reason) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/entry/$postId/report';

        final response = await httpClient.post(
          Uri.https(server, path),
          body: jsonEncode({
            'reason': reason,
          }),
        );

        httpErrorHandler(response, message: "Failed to report post");

      case ServerSoftware.lemmy:
        const path = '/api/v3/post/report';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'post_id': postId,
            'reason': reason,
          }),
        );

        httpErrorHandler(response, message: "Failed to report post");
    }
  }
}
