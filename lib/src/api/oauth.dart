import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/redirect_listen.dart';

const oauthName = 'Interstellar';
const oauthContact = 'contact@kbin.earth';
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

Future<String> registerOAuthApp(
  String instanceHost,
) async {
  final response = await http.post(Uri.https(instanceHost, '/api/client'),
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
      }));

  httpErrorHandler(response, message: 'Failed to register client');

  return (jsonDecode(response.body) as Map<String, dynamic>)['identifier'];
}
