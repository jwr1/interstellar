import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/markdown_editor.dart';
import 'package:provider/provider.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen();

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {

  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _magazineTextController = TextEditingController();

  bool _isOc = false;
  bool _isAdult = false;

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create"),
        actions: [
          IconButton(
            onPressed: () async {
              var magazineName = _magazineTextController.text;
              var client = context.read<SettingsController>().httpClient;
              var instanceHost = context.read<SettingsController>().instanceHost;

              final magazine = await api_magazines.fetchMagazineByName(
                  client,
                  instanceHost,
                  magazineName);

              var title = _titleTextController.text;
              var body = _bodyTextController.text;
              api_entries.createEntry(
                  client,
                  instanceHost,
                  magazine.magazineId,
                  title,
                  _isOc,
                  body,
                  'en',
                  _isAdult)
              .then((value) {
                    Navigator.pop(context);
              });
            },
            icon: const Icon(Icons.send))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(5),
                child: MarkdownEditor(
                  _titleTextController,
                  hintText: "Title",
                )
            ),
            Padding(
                padding: const EdgeInsets.all(5),
                child: MarkdownEditor(
                  _bodyTextController,
                  hintText: "Body",
                )
            ),
            Padding(
                padding: const EdgeInsets.all(5),
                child: MarkdownEditor(
                  _magazineTextController,
                  hintText: "Magazine",
                )
            ),
            Row(
              children: [
                Checkbox(
                  value: _isOc,
                  onChanged: (bool? value) => setState(() {
                    _isOc = value!;
                  }),
                ),
                const Text("OC"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isAdult,
                  onChanged: (bool? value) => setState(() {
                    _isAdult = value!;
                  })
                ),
                const Text("NSFW")
              ],
            ),
          ],
        ),
      )
    );
  }

}