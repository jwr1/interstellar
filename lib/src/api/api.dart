import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/bookmark.dart';
import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/api/domains.dart';
import 'package:interstellar/src/api/magazine_moderation.dart';
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/api/messages.dart';
import 'package:interstellar/src/api/microblogs.dart';
import 'package:interstellar/src/api/moderation.dart';
import 'package:interstellar/src/api/notifications.dart';
import 'package:interstellar/src/api/search.dart';
import 'package:interstellar/src/api/threads.dart';
import 'package:interstellar/src/api/users.dart';
import 'package:interstellar/src/controller/server.dart';

class API {
  final ServerClient client;

  final APIComments comments;
  final MbinAPIDomains domains;
  final APIThreads threads;
  final APIMagazines magazines;
  final APIMagazineModeration magazineModeration;
  final APIMessages messages;
  final APIModeration moderation;
  final MbinAPINotifications notifications;
  final MbinAPIMicroblogs microblogs;
  final APISearch search;
  final APIUsers users;
  final APIBookmark bookmark;

  API(this.client)
      : comments = APIComments(client),
        domains = MbinAPIDomains(client),
        threads = APIThreads(client),
        magazines = APIMagazines(client),
        magazineModeration = APIMagazineModeration(client),
        messages = APIMessages(client),
        moderation = APIModeration(client),
        notifications = MbinAPINotifications(client),
        microblogs = MbinAPIMicroblogs(client),
        search = APISearch(client),
        users = APIUsers(client),
        bookmark = APIBookmark(client);
}

Future<ServerSoftware?> getServerSoftware(String server) async {
  final response = await http.get(Uri.https(server, '/nodeinfo/2.0.json'));

  try {
    return ServerSoftware.values.byName(((response.bodyJson['software']
            as Map<String, Object?>)['name'] as String)
        .toLowerCase());
  } catch (_) {
    return null;
  }
}
