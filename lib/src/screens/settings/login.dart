import 'package:flutter/material.dart';
import 'package:interstellar/src/api/oauth.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/redirect_listen.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:provider/provider.dart';

final List<String> _recommendedInstances = [
  'kbin.earth',
  'kbin.run',
  'kbin.melroy.org',
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _instanceHostController =
      TextEditingController(text: _recommendedInstances.first);

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
            child: TextField(
              controller: _instanceHostController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Instance Host')),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                  onPressed: () async {
                    final instanceHost = _instanceHostController.text;

                    final authorizationEndpoint =
                        Uri.https(instanceHost, '/authorize');
                    final tokenEndpoint = Uri.https(instanceHost, '/token');

                    try {
                      String identifier = await context
                          .read<SettingsController>()
                          .getOAuthIdentifier(instanceHost);

                      var grant = oauth2.AuthorizationCodeGrant(
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
                                  title: instanceHost,
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

                      var user = await api_users.fetchMe(client, instanceHost);

                      // Check BuildContext
                      if (!mounted) return;

                      String account = '${user.username}@$instanceHost';
                      context.read<SettingsController>().setOAuthCredentials(
                            account,
                            client.credentials,
                            switchNow: true,
                          );

                      Navigator.pop(context);
                    } catch (e) {
                      // Check BuildContext
                      if (!mounted) return;

                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(e.toString()),
                          duration: const Duration(seconds: 15),
                        ));
                    }
                  },
                  child: const Text('Login')),
              const SizedBox(width: 12),
              OutlinedButton(
                  onPressed: () {
                    final instanceHost = _instanceHostController.text;

                    String account = '@$instanceHost';
                    context
                        .read<SettingsController>()
                        .setOAuthCredentials(account, null, switchNow: true);

                    Navigator.pop(context);
                  },
                  child: const Text('Anonymous')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(children: [
              Text('Recommended Instances',
                  style: Theme.of(context).textTheme.headlineSmall),
              ..._recommendedInstances.map((v) => ListTile(
                    title: Text(v),
                    onTap: () => setState(() {
                      _instanceHostController.text = v;
                    }),
                  ))
            ]),
          ),
        ],
      ),
    );
  }
}
