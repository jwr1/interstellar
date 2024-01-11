import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/utils/utils.dart';

// new_ is used because new is a reserved keyword
enum NotificationsFilter { all, new_, read }

Future<NotificationListModel> fetchNotifications(
  http.Client client,
  String instanceHost, {
  int? page,
  NotificationsFilter? filter,
}) async {
  final filterName =
      filter == NotificationsFilter.new_ ? 'new' : (filter?.name ?? 'all');

  final response = await client.get(Uri.https(
      instanceHost, '/api/notifications/$filterName', {'p': page?.toString()}));

  httpErrorHandler(response, message: 'Failed to load notifications');

  return NotificationListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<int> fetchNotificationCount(
  http.Client client,
  String instanceHost,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/notifications/count'));

  httpErrorHandler(response, message: 'Failed to load notification count');

  return jsonDecode(response.body)['count'];
}
