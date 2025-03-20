import 'dart:convert';

import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/notification.dart';

// TODO: add missing switch statements to this file

// new_ is used because new is a reserved keyword
enum NotificationsFilter { all, new_, read }

enum NotificationControlUpdateTargetType {
  entry,
  post,
  magazine,
  user,
  comment,
}

class MbinAPINotifications {
  final ServerClient client;

  MbinAPINotifications(this.client);

  Future<NotificationListModel> list({
    String? page,
    NotificationsFilter? filter,
  }) async {
    final path =
        '/notifications/${filter == NotificationsFilter.new_ ? 'new' : (filter?.name ?? 'all')}';
    final query = {'p': page};

    final response =
        await client.send(HttpMethod.get, path, queryParams: query);

    return NotificationListModel.fromMbin(response.bodyJson);
  }

  Future<int> getCount() async {
    switch (client.software) {
      case ServerSoftware.mbin:
        const path = '/notifications/count';

        final response = await client.send(HttpMethod.get, path);

        return response.bodyJson['count'] as int;

      case ServerSoftware.lemmy:
        const path = '/user/unread_count';

        final response = await client.send(HttpMethod.get, path);

        return (response.bodyJson['replies'] as int) +
            (response.bodyJson['mentions'] as int) +
            (response.bodyJson['private_messages'] as int);

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<void> putReadAll() async {
    const path = '/notifications/read';

    final response = await client.send(HttpMethod.put, path);
  }

  Future<NotificationModel> putRead(
    int notificationId,
    bool readState,
  ) async {
    final path =
        '/notifications/$notificationId/${readState ? 'read' : 'unread'}';

    final response = await client.send(HttpMethod.put, path);

    return NotificationModel.fromMbin(response.bodyJson);
  }

  // Returns server's public key
  Future<void> pushRegister({
    required String endpoint,
    required String serverKey,
    required String contentPublicKey,
  }) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        const path = '/notification/push';

        final response = await client.send(
          HttpMethod.post,
          path,
          body: {
            'endpoint': endpoint,
            'serverKey': serverKey,
            'contentPublicKey': contentPublicKey
          },
        );

        return;

      case ServerSoftware.lemmy:
        throw Exception('Notifications not yet implemented on Lemmy');

      case ServerSoftware.piefed:
        throw Exception('Notifications not yet implemented on PieFed');
    }
  }

  Future<void> pushDelete() async {
    switch (client.software) {
      case ServerSoftware.mbin:
        const path = '/notification/push';

        final response = await client.send(
          HttpMethod.delete,
          path,
        );

        return;

      case ServerSoftware.lemmy:
        throw Exception('Notifications not yet implemented on Lemmy');

      case ServerSoftware.piefed:
        throw Exception('Notifications not yet implemented on PieFed');
    }
  }

  Future<void> updateControl({
    required NotificationControlUpdateTargetType targetType,
    required int targetId,
    required NotificationControlStatus status,
  }) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path =
            '/notification/update/${targetType.name}/$targetId/${status.toJson()}';

        final response = await client.send(
          HttpMethod.put,
          path,
        );

        return;

      case ServerSoftware.lemmy:
        throw Exception('Notification update control not implemented on Lemmy');

      case ServerSoftware.piefed:
        final path = switch (targetType) {
          NotificationControlUpdateTargetType.entry => '/post/subscribe',
          NotificationControlUpdateTargetType.post =>
            throw UnsupportedError('Microblogs not on PieFed'),
          NotificationControlUpdateTargetType.magazine =>
            '/community/subscribe',
          NotificationControlUpdateTargetType.user => '/user/subscribe',
          NotificationControlUpdateTargetType.comment => '/comment/subscribe',
        };

        final response = await client.send(
          HttpMethod.put,
          path,
          body: {
            switch (targetType) {
              NotificationControlUpdateTargetType.entry => 'post_id',
              NotificationControlUpdateTargetType.post =>
                throw UnsupportedError('Microblogs not on PieFed'),
              NotificationControlUpdateTargetType.magazine => 'community_id',
              NotificationControlUpdateTargetType.user => 'person_id',
              NotificationControlUpdateTargetType.comment => 'comment_id',
            }: targetId,
            'subscribe': status == NotificationControlStatus.loud,
          },
        );
    }
  }
}
