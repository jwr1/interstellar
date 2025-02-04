import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/utils/utils.dart';

// new_ is used because new is a reserved keyword
enum NotificationsFilter { all, new_, read }

enum NotificationControlUpdateTargetType { entry, post, magazine, user }

class MbinAPINotifications {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  MbinAPINotifications(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<NotificationListModel> list({
    String? page,
    NotificationsFilter? filter,
  }) async {
    final path =
        '/api/notifications/${filter == NotificationsFilter.new_ ? 'new' : (filter?.name ?? 'all')}';
    final query = queryParams({'p': page});

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load notifications');

    return NotificationListModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<int> getCount() async {
    switch (software) {
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

    return NotificationModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  // Returns server's public key
  Future<void> pushRegister({
    required String endpoint,
    required String serverKey,
    required String contentPublicKey,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        const path = '/api/notification/push';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'endpoint': endpoint,
            'serverKey': serverKey,
            'contentPublicKey': contentPublicKey
          }),
        );

        httpErrorHandler(response, message: 'Failed to send register push');

        return;

      case ServerSoftware.lemmy:
        throw Exception('Notifications not yet implemented on Lemmy');
    }
  }

  Future<void> pushDelete() async {
    switch (software) {
      case ServerSoftware.mbin:
        const path = '/api/notification/push';

        final response = await httpClient.delete(
          Uri.https(server, path),
        );

        httpErrorHandler(response, message: 'Failed to send delete push');

        return;

      case ServerSoftware.lemmy:
        throw Exception('Notifications not yet implemented on Lemmy');
    }
  }

  Future<void> updateControl({
    required NotificationControlUpdateTargetType targetType,
    required int targetId,
    required NotificationControlStatus status,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path =
            '/api/notification/update/${targetType.name}/$targetId/${status.toJson()}';

        final response = await httpClient.put(
          Uri.https(server, path),
        );

        httpErrorHandler(response,
            message: 'Failed to update notification control');

        return;

      case ServerSoftware.lemmy:
        throw Exception(
            'Notification update control not yet implemented on Lemmy');
    }
  }
}
