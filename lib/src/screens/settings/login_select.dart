import 'package:flutter/material.dart';
import 'package:interstellar/src/api/api.dart';
import 'package:interstellar/src/screens/settings/login_confirm.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

final List<String> _recommendedInstances = [
  'kbin.earth',
  'fedia.io',
  'thebrainbin.org',
  'kbin.melroy.org',
  'lemm.ee',
  'lemmy.ml',
  'lemmy.world',
  'programming.dev',
];

class LoginSelectScreen extends StatefulWidget {
  const LoginSelectScreen({super.key});

  @override
  State<LoginSelectScreen> createState() => _LoginSelectScreenState();
}

class _LoginSelectScreenState extends State<LoginSelectScreen> {
  final TextEditingController _instanceHostController = TextEditingController();

  Future<void> _initiateLogin(String host) async {
    final software = await getServerSoftware(host);
    if (software == null) {
      throw Exception('$host is using unsupported software');
    }

    // Check BuildContext
    if (!mounted) return;

    await context.read<SettingsController>().saveServer(software, host);

    // Check BuildContext
    if (!mounted) return;

    final shouldPop = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginConfirmScreen(
          software,
          host,
        ),
      ),
    );

    if (shouldPop == true) {
      // Check BuildContext
      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextEditor(
                  _instanceHostController,
                  label: 'Instance Host',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _instanceHostController.text.isEmpty
                      ? null
                      : () => _initiateLogin(_instanceHostController.text),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(
                'Recommended Instances',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              ..._recommendedInstances.map((v) => ListTile(
                    title: Text(v),
                    onTap: () => _initiateLogin(v),
                  ))
            ]),
          ),
        ],
      ),
    );
  }
}
