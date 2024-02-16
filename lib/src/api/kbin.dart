import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/domains.dart';
import 'package:interstellar/src/api/entries.dart';
import 'package:interstellar/src/api/entry_comments.dart';
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/api/messages.dart';
import 'package:interstellar/src/api/notifications.dart';
import 'package:interstellar/src/api/oauth.dart';
import 'package:interstellar/src/api/post_comments.dart';
import 'package:interstellar/src/api/posts.dart';
import 'package:interstellar/src/api/search.dart';
import 'package:interstellar/src/api/users.dart';

class KbinAPI {
  final http.Client httpClient;
  final String instanceHost;

  final KbinAPIOAuth oauth;
  final KbinAPIDomains domains;
  final KbinAPIEntries entries;
  final KbinAPIEntryComments entryComments;
  final KbinAPIMagazines magazines;
  final KbinAPIMessages messages;
  final KbinAPINotifications notifications;
  final KbinAPIPosts posts;
  final KbinAPIPostComments postComments;
  final KbinAPISearch search;
  final KbinAPIUsers users;

  KbinAPI(
    this.httpClient,
    this.instanceHost,
  )   : oauth = KbinAPIOAuth(httpClient, instanceHost),
        domains = KbinAPIDomains(httpClient, instanceHost),
        entries = KbinAPIEntries(httpClient, instanceHost),
        entryComments = KbinAPIEntryComments(httpClient, instanceHost),
        magazines = KbinAPIMagazines(httpClient, instanceHost),
        messages = KbinAPIMessages(httpClient, instanceHost),
        notifications = KbinAPINotifications(httpClient, instanceHost),
        posts = KbinAPIPosts(httpClient, instanceHost),
        postComments = KbinAPIPostComments(httpClient, instanceHost),
        search = KbinAPISearch(httpClient, instanceHost),
        users = KbinAPIUsers(httpClient, instanceHost);
}
