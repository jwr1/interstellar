import 'package:flutter/material.dart';
import 'package:interstellar/src/api/api.dart';
import 'package:interstellar/src/screens/settings/login_confirm.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

final List<String> _recommendedInstances = [
  'kbin.earth',
  'kbin.run',
  'kbin.melroy.org',
  'lemm.ee',
  'lemmy.ml',
  'programming.dev',
];

class LoginSelectScreen extends StatefulWidget {
  const LoginSelectScreen({super.key});

  @override
  State<LoginSelectScreen> createState() => _LoginSelectScreenState();
}

class _LoginSelectScreenState extends State<LoginSelectScreen> {
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextEditor(_instanceHostController, label: 'Instance Host'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    final software =
                        await getServerSoftware(_instanceHostController.text);
                    if (software == null) {
                      throw Exception(
                          '${_instanceHostController.text} is using unsupported software');
                    }

                    // Check BuildContext
                    if (!mounted) return;

                    await context
                        .read<SettingsController>()
                        .saveServer(software, _instanceHostController.text);

                    // Check BuildContext
                    if (!mounted) return;

                    final shouldPop = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginConfirmScreen(
                          software,
                          _instanceHostController.text,
                        ),
                      ),
                    );

                    if (shouldPop == true) {
                      // Check BuildContext
                      if (!mounted) return;

                      Navigator.pop(context);
                    }
                  },
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
