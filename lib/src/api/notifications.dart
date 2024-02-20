import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';

// new_ is used because new is a reserved keyword
enum NotificationsFilter { all, new_, read }

class KbinAPINotifications {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  KbinAPINotifications(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<NotificationListModel> list({
    int? page,
    NotificationsFilter? filter,
  }) async {
    final path =
        '/api/notifications/${filter == NotificationsFilter.new_ ? 'new' : (filter?.name ?? 'all')}';
    final query = queryParams({'p': page?.toString()});

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load notifications');

    return NotificationListModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<int> getCount() async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        const path = '/api/notifications/count';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response,
            message: 'Failed to load notification count');

        return jsonDecode(response.body)['count'];

      case ServerSoftware.lemmy:
        const path = '/api/v3/user/unread_count';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response,
            message: 'Failed to load notification count');

        return (jsonDecode(response.body)['replies'] as int) +
            (jsonDecode(response.body)['mentions'] as int) +
            (jsonDecode(response.body)['private_messages'] as int);
    }
  }

  Future<void> putReadAll() async {
    const path = '/api/notifications/read';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to mark notifications');
  }

  Future<NotificationModel> putRead(
    int notificationId,
    bool readState,
  ) async {
    final path =
        '/api/notifications/$notificationId/${readState ? 'read' : 'unread'}';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to mark notification');

    return NotificationModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
