import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/old/notification.dart';
import 'package:interstellar/src/utils/utils.dart';

// new_ is used because new is a reserved keyword
enum NotificationsFilter { all, new_, read }

class KbinAPINotifications {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPINotifications(
    this.httpClient,
    this.instanceHost,
  );

  Future<NotificationListModel> list({
    int? page,
    NotificationsFilter? filter,
  }) async {
    final path =
        '/api/notifications/${filter == NotificationsFilter.new_ ? 'new' : (filter?.name ?? 'all')}';
    final query = queryParams({'p': page?.toString()});

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load notifications');

    return NotificationListModel.fromJson(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<int> getCount() async {
    const path = '/api/notifications/count';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load notification count');

    return jsonDecode(response.body)['count'];
  }

  Future<void> putReadAll() async {
    const path = '/api/notifications/read';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to mark notifications');
  }

  Future<NotificationModel> putRead(
    int notificationId,
    bool readState,
  ) async {
    final path =
        '/api/notifications/$notificationId/${readState ? 'read' : 'unread'}';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to mark notification');

    return NotificationModel.fromJson(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
