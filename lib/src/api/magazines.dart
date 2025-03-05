import 'dart:convert';

import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/explore/explore_screen.dart';
import 'package:interstellar/src/utils/models.dart';

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
  final ServerClient client;

  APIMagazines(this.client);

  Future<DetailedMagazineListModel> list({
    String? page,
    ExploreFilter? filter,
    APIMagazinesSort? sort,
    String? search,
  }) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = (filter == null ||
                filter == ExploreFilter.all ||
                filter == ExploreFilter.local)
            ? '/magazines'
            : '/magazines/${filter.name}';
        final query = {
          'p': page,
          if (filter == null ||
              filter == ExploreFilter.all ||
              filter == ExploreFilter.local) ...{
            'sort': sort?.name,
            'q': search,
            'federation': filter == ExploreFilter.local ? 'local' : null,
          },
        };

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        return DetailedMagazineListModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        if (search == null) {
          const path = '/community/list';
          final query = {
            'type_': switch (filter) {
              ExploreFilter.all => 'All',
              ExploreFilter.local => 'Local',
              ExploreFilter.moderated => 'ModeratorView',
              ExploreFilter.subscribed => 'Subscribed',
              ExploreFilter.blocked =>
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
              _ => 'TopAll'
            },
            'page': page,
          };

          final response =
              await client.send(HttpMethod.get, path, queryParams: query);

          final json = response.bodyJson;

          json['next_page'] =
              lemmyCalcNextIntPage(json['communities'] as List<dynamic>, page);

          return DetailedMagazineListModel.fromLemmy(json);
        } else {
          const path = '/search';
          final query = {
            'type_': 'Communities',
            'listing_type': switch (filter) {
              ExploreFilter.all => 'All',
              ExploreFilter.local => 'Local',
              ExploreFilter.moderated => 'ModeratorView',
              ExploreFilter.subscribed => 'Subscribed',
              ExploreFilter.blocked =>
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
          };

          final response =
              await client.send(HttpMethod.get, path, queryParams: query);

          final json = response.bodyJson;

          json['next_page'] =
              lemmyCalcNextIntPage(json['communities'] as List<dynamic>, page);

          return DetailedMagazineListModel.fromLemmy(json);
        }

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<DetailedMagazineModel> get(int magazineId) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = '/magazine/$magazineId';

        final response = await client.send(HttpMethod.get, path);

        return DetailedMagazineModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        const path = '/community';
        final query = {'id': magazineId.toString()};

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        return DetailedMagazineModel.fromLemmy(
            response.bodyJson['community_view'] as Map<String, Object?>);

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<DetailedMagazineModel> getByName(String magazineName) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = '/magazine/name/$magazineName';

        final response = await client.send(HttpMethod.get, path);

        return DetailedMagazineModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        const path = '/community';
        final query = {'name': magazineName.toString()};

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        return DetailedMagazineModel.fromLemmy(
            response.bodyJson['community_view'] as Map<String, Object?>);

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<DetailedMagazineModel> subscribe(int magazineId, bool state) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path =
            '/magazine/$magazineId/${state ? 'subscribe' : 'unsubscribe'}';

        final response = await client.send(HttpMethod.put, path);

        return DetailedMagazineModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        const path = '/community/follow';

        final response = await client.send(
          HttpMethod.post,
          path,
          body: {
            'community_id': magazineId,
            'follow': state,
          },
        );

        return DetailedMagazineModel.fromLemmy(
            response.bodyJson['community_view'] as Map<String, Object?>);

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<DetailedMagazineModel> block(int magazineId, bool state) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = '/magazine/$magazineId/${state ? 'block' : 'unblock'}';

        final response = await client.send(HttpMethod.put, path);

        return DetailedMagazineModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        const path = '/community/block';

        final response = await client.send(
          HttpMethod.post,
          path,
          body: {
            'community_id': magazineId,
            'block': state,
          },
        );

        return DetailedMagazineModel.fromLemmy(
            response.bodyJson['community_view'] as Map<String, Object?>);

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }
}
