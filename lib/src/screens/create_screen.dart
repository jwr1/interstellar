import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/markdown_editor.dart';
import 'package:provider/provider.dart';

enum CreateType { entry, link, image, post }

class CreateScreen extends StatefulWidget {
  const CreateScreen(
    this.type,
    {
      this.magazineId,
      this.magazineName,
      super.key
    }
  );

  final CreateType type;
  final int? magazineId;
  final String? magazineName;

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();
  final TextEditingController _tagsTextController = TextEditingController();
  final TextEditingController _magazineTextController = TextEditingController();
  bool _isOc = false;
  bool _isAdult = false;

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

              int? magazineId = widget.magazineId;
              if (magazineId == null) {
                final magazine = await api_magazines.fetchMagazineByName(
                    client,
                    instanceHost,
                    magazineName);
                magazineId = magazine.magazineId;
              }

              var tags = _tagsTextController.text.split(' ');

              switch (widget.type) {
                case CreateType.entry:
                  await api_entries.createEntry(
                    client,
                    instanceHost,
                    magazineId,
                    _titleTextController.text,
                    _isOc,
                    _bodyTextController.text,
                    'en',
                    _isAdult,
                    tags
                  );
                case CreateType.link:
                  await api_entries.createLink(
                    client,
                    instanceHost,
                    magazineId,
                    _titleTextController.text,
                    _urlTextController.text,
                    _isOc,
                    _bodyTextController.text,
                    'en',
                    _isAdult,
                    tags
                  );
                case CreateType.image:
                  //TODO: implement image selection.
                  break;
                case CreateType.post:
                  await api_posts.createPost(
                    client,
                    instanceHost,
                    magazineId,
                    _bodyTextController.text,
                    'en',
                    _isAdult);
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.send))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (widget.type != CreateType.post)
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
            if (widget.type == CreateType.link)
              Padding(
                padding: const EdgeInsets.all(5),
                child: MarkdownEditor(
                  _urlTextController,
                  hintText: "URL",
                )
              ),
            if (widget.type != CreateType.post)
              Padding(
                padding: const EdgeInsets.all(5),
                child: MarkdownEditor(
                  _tagsTextController,
                  hintText: "Tags",
                )
              ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: MarkdownEditor(
                _magazineTextController..text = widget.magazineName ?? '',
                hintText: "Magazine",
              )
            ),
            if (widget.type != CreateType.post)
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