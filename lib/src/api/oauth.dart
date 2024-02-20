import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/redirect_listen.dart';

const oauthName = 'Interstellar';
const oauthContact = 'appstore@jwr.one';
const oauthGrants = ['authorization_code', 'refresh_token'];
const oauthScopes = [
  'read',
  'write',
  'delete',
  'subscribe',
  'block',
  'vote',
  'report',
  'user',
  'moderate'
];

class KbinAPIOAuth {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  KbinAPIOAuth(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<String> registerApp(String instanceHost) async {
    const path = '/api/client';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': oauthName,
        'contactEmail': oauthContact,
        'public': true,
        'redirectUris': [redirectUri],
        'grants': oauthGrants,
        'scopes': oauthScopes
      }),
    );

    httpErrorHandler(response, message: 'Failed to register client');

    return (jsonDecode(response.body) as Map<String, dynamic>)['identifier'];
  }
}
