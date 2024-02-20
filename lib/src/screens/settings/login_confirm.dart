import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/api.dart';
import 'package:interstellar/src/api/oauth.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/jwt_http_client.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/redirect_listen.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:provider/provider.dart';

class LoginConfirmScreen extends StatefulWidget {
  final ServerSoftware software;
  final String server;

  const LoginConfirmScreen(this.software, this.server, {super.key});

  @override
  State<LoginConfirmScreen> createState() => _LoginConfirmScreenState();
}

class _LoginConfirmScreenState extends State<LoginConfirmScreen> {
  final _usernameEmailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _totpTokenTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.server,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  widget.software.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          if (widget.software == ServerSoftware.lemmy)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                TextEditor(
                  _usernameEmailTextController,
                  label: 'Username or Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextEditor(
                  _passwordTextController,
                  label: 'Password',
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 12),
                TextEditor(
                  _totpTokenTextController,
                  label: '2fa token',
                  keyboardType: TextInputType.visiblePassword,
                ),
              ]),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  if (widget.software == ServerSoftware.lemmy) {
                    final loginEndpoint =
                        Uri.https(widget.server, '/api/v3/user/login');

                    final response = await http.post(
                      loginEndpoint,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'username_or_email': _usernameEmailTextController.text,
                        'password': _passwordTextController.text,
                        'totp_2fa_token': _totpTokenTextController.text.isEmpty
                            ? null
                            : _totpTokenTextController.text.isEmpty,
                      }),
                    );
                    httpErrorHandler(response, message: 'Failed to login');

                    final jwt = jsonDecode(response.body)['jwt'];
                    final user = await API(
                            widget.software, JwtHttpClient(jwt), widget.server)
                        .users
                        .getMe();

                    // Check BuildContext
                    if (!mounted) return;
                    context.read<SettingsController>().setAccount(
                        '${user.name}@${widget.server}',
                        Account(jwt: jsonDecode(response.body)['jwt']));
                  } else {
                    final authorizationEndpoint =
                        Uri.https(widget.server, '/authorize');
                    final tokenEndpoint = Uri.https(widget.server, '/token');

                    String identifier = await context
                        .read<SettingsController>()
                        .getKbinOAuthIdentifier(widget.software, widget.server);

                    final grant = oauth2.AuthorizationCodeGrant(
                      identifier,
                      authorizationEndpoint,
                      tokenEndpoint,
                    );

                    Uri authorizationUrl = grant.getAuthorizationUrl(
                        Uri.parse(redirectUri),
                        scopes: oauthScopes);

                    // Check BuildContext
                    if (!mounted) return;

                    Map<String, String>? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RedirectListener(
                                authorizationUrl,
                                title: widget.server,
                              )),
                    );

                    if (result == null || !result.containsKey('code')) {
                      throw Exception(
                        result?['message'] != null
                            ? result!['message']
                            : 'unsuccessful login',
                      );
                    }

                    var client =
                        await grant.handleAuthorizationResponse(result);

                    var user = await API(widget.software, client, widget.server)
                        .users
                        .getMe();

                    // Check BuildContext
                    if (!mounted) return;

                    context.read<SettingsController>().setAccount(
                          '${user.name}@${widget.server}',
                          Account(oauth: client.credentials),
                          switchNow: true,
                        );
                  }

                  Navigator.pop(context, true);
                },
                child: const Text('Login'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  String account = '@${widget.server}';
                  context
                      .read<SettingsController>()
                      .setAccount(account, Account(), switchNow: true);

                  Navigator.pop(context, true);
                },
                child: const Text('Anonymous'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
