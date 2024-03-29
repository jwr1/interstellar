import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/api/domains.dart';
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/api/messages.dart';
import 'package:interstellar/src/api/microblogs.dart';
import 'package:interstellar/src/api/notifications.dart';
import 'package:interstellar/src/api/search.dart';
import 'package:interstellar/src/api/threads.dart';
import 'package:interstellar/src/api/users.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';

class API {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  final APIComments comments;
  final KbinAPIDomains domains;
  final APIThreads threads;
  final APIMagazines magazines;
  final KbinAPIMessages messages;
  final KbinAPINotifications notifications;
  final KbinAPIMicroblogs microblogs;
  final APISearch search;
  final APIUsers users;

  API(
    this.software,
    this.httpClient,
    this.server,
  )   : comments = APIComments(software, httpClient, server),
        domains = KbinAPIDomains(software, httpClient, server),
        threads = APIThreads(software, httpClient, server),
        magazines = APIMagazines(software, httpClient, server),
        messages = KbinAPIMessages(software, httpClient, server),
        notifications = KbinAPINotifications(software, httpClient, server),
        microblogs = KbinAPIMicroblogs(software, httpClient, server),
        search = APISearch(software, httpClient, server),
        users = APIUsers(software, httpClient, server);
}

Future<ServerSoftware?> getServerSoftware(String server) async {
  final response = await http.get(Uri.https(server, '/nodeinfo/2.0.json'));

  httpErrorHandler(response, message: 'Failed to load nodeinfo');

  try {
    return ServerSoftware.values
        .byName(jsonDecode(response.body)['software']['name']);
  } catch (_) {
    return null;
  }
}
