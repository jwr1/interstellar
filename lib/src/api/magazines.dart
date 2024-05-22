import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/models.dart';
import 'package:interstellar/src/utils/utils.dart';

enum APIMagazinesFilter { all, local, subscribed, moderated, blocked }

enum APIMagazinesSort {
  active,
  hot,
  newest,

  //lemmy specific
  top,
  oldest,
  commented,
  newComments,
  topDay,
  topWeek,
  topMonth,
  topYear,
  topHour,
  topSixHour,
  topTwelveHour,
  topThreeMonths,
  topSixMonths,
  topNineMonths,
  controversial,
  scaled,
}



class APIMagazines {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIMagazines(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<DetailedMagazineListModel> list({
    String? page,
    APIMagazinesFilter? filter,
    APIMagazinesSort? sort,
    String? search,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = (filter == null ||
                filter == APIMagazinesFilter.all ||
                filter == APIMagazinesFilter.local)
            ? '/api/magazines'
            : '/api/magazines/${filter.name}';
        final query = queryParams(
          (filter == null ||
                  filter == APIMagazinesFilter.all ||
                  filter == APIMagazinesFilter.local)
              ? {
                  'p': page,
                  'sort': sort?.name,
                  'q': search,
                  'federation':
                      filter == APIMagazinesFilter.local ? 'local' : null,
                }
              : {'p': page},
        );

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load magazines');

        return DetailedMagazineListModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        if (search == null) {
          const path = '/api/v3/community/list';
          final query = queryParams({
            'type_': switch (filter) {
              APIMagazinesFilter.all => 'All',
              APIMagazinesFilter.local => 'Local',
              APIMagazinesFilter.moderated => 'ModeratorView',
              APIMagazinesFilter.subscribed => 'Subscribed',
              APIMagazinesFilter.blocked =>
                throw Exception('Can not filter magazines by blocked on Lemmy'),
              null => 'All'
            },
            'limit': '50',
            'sort': switch (sort) {
              APIMagazinesSort.active => 'Active',
              APIMagazinesSort.hot => 'Hot',
              APIMagazinesSort.newest => 'New',
              APIMagazinesSort.top => 'TopAll',
              APIMagazinesSort.oldest => 'Old',
              APIMagazinesSort.commented => 'MostComments',
              APIMagazinesSort.newComments => 'NewComments',
              APIMagazinesSort.topDay => 'TopDay',
              APIMagazinesSort.topWeek => 'TopWeek',
              APIMagazinesSort.topMonth => 'TopMonth',
              APIMagazinesSort.topYear => 'TopYear',
              APIMagazinesSort.topHour => 'TopHour',
              APIMagazinesSort.topSixHour => 'TopSixHour',
              APIMagazinesSort.topTwelveHour => 'TopTwelveHour',
              APIMagazinesSort.topThreeMonths => 'TopThreeMonths',
              APIMagazinesSort.topSixMonths => 'TopSixMonths',
              APIMagazinesSort.topNineMonths => 'TopNineMonths',
              APIMagazinesSort.controversial => 'Controversial',
              APIMagazinesSort.scaled => 'Scaled',
              _ => 'All'
            },
            'page': page,
          });

          final response = await httpClient.get(Uri.https(server, path, query));

          httpErrorHandler(response, message: 'Failed to load magazines');

          final json = jsonDecode(response.body) as Map<String, Object?>;

          json['next_page'] =
              lemmyCalcNextIntPage(json['communities'] as List<dynamic>, page);

          return DetailedMagazineListModel.fromLemmy(json);
        } else {
          const path = '/api/v3/search';
          final query = queryParams({
            'type_': 'Communities',
            'listing_type': switch (filter) {
              APIMagazinesFilter.all => 'All',
              APIMagazinesFilter.local => 'Local',
              APIMagazinesFilter.moderated => 'ModeratorView',
              APIMagazinesFilter.subscribed => 'Subscribed',
              APIMagazinesFilter.blocked =>
                throw Exception('Can not filter magazines by blocked on Lemmy'),
              null => 'All'
            },
            'limit': '50',
            'sort': switch (sort) {
              APIMagazinesSort.active => 'Active',
              APIMagazinesSort.hot => 'TopAll',
              APIMagazinesSort.newest => 'New',
              _ => 'All'
            },
            'page': page,
            'q': search,
          });

          final response = await httpClient.get(Uri.https(server, path, query));

          httpErrorHandler(response, message: 'Failed to load magazines');

          final json = jsonDecode(response.body) as Map<String, Object?>;

          json['next_page'] =
              lemmyCalcNextIntPage(json['communities'] as List<dynamic>, page);

          return DetailedMagazineListModel.fromLemmy(json);
        }
    }
  }

  Future<DetailedMagazineModel> get(int magazineId) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/magazine/$magazineId';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load magazine');

        return DetailedMagazineModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/community';
        final query = queryParams({
          'id': magazineId.toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load magazine');

        return DetailedMagazineModel.fromLemmy(
            jsonDecode(response.body)['community_view']
                as Map<String, Object?>);
    }
  }

  Future<DetailedMagazineModel> getByName(String magazineName) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/magazine/name/$magazineName';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load magazine');

        return DetailedMagazineModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/community';
        final query = queryParams({
          'name': magazineName.toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load magazine');

        return DetailedMagazineModel.fromLemmy(
            jsonDecode(response.body)['community_view']
                as Map<String, Object?>);
    }
  }

  Future<DetailedMagazineModel> subscribe(int magazineId, bool state) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path =
            '/api/magazine/$magazineId/${state ? 'subscribe' : 'unsubscribe'}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send subscribe');

        return DetailedMagazineModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/community/follow';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'community_id': magazineId,
            'follow': state,
          }),
        );

        httpErrorHandler(response, message: 'Failed to send subscribe');

        return DetailedMagazineModel.fromLemmy(
            jsonDecode(response.body)['community_view']
                as Map<String, Object?>);
    }
  }

  Future<DetailedMagazineModel> block(int magazineId, bool state) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/magazine/$magazineId/${state ? 'block' : 'unblock'}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send block');

        return DetailedMagazineModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/community/block';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'community_id': magazineId,
            'block': state,
          }),
        );

        httpErrorHandler(response, message: 'Failed to send block');

        return DetailedMagazineModel.fromLemmy(
            jsonDecode(response.body)['community_view']
                as Map<String, Object?>);
    }
  }
}
