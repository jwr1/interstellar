import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum CreateType { entry, post }

class CreateScreen extends StatefulWidget {
  const CreateScreen(
    this.type, {
    this.magazineId,
    this.magazineName,
    super.key,
  });

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
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create ${switch (widget.type) {
          CreateType.entry => 'thread',
          CreateType.post => 'post',
        }}"),
        actions: [
          IconButton(
              onPressed: () async {
                var magazineName = _magazineTextController.text;
                var client = context.read<SettingsController>().httpClient;
                var instanceHost =
                    context.read<SettingsController>().instanceHost;

                int? magazineId = widget.magazineId;
                if (magazineId == null) {
                  final magazine = await api_magazines.fetchMagazineByName(
                    client,
                    instanceHost,
                    magazineName,
                  );
                  magazineId = magazine.magazineId;
                }

                var tags = _tagsTextController.text.isNotEmpty ? _tagsTextController.text.split(' ') : <String>[];

                switch (widget.type) {
                  case CreateType.entry:
                    if (_urlTextController.text.isEmpty) {
                      if (_imageFile == null) {
                        await api_entries.createEntry(
                          client,
                          instanceHost,
                          magazineId,
                          title: _titleTextController.text,
                          isOc: _isOc,
                          body: _bodyTextController.text,
                          lang: 'en',
                          isAdult: _isAdult,
                          tags: tags,
                        );
                      } else {
                        await api_entries.createImage(
                          client,
                          instanceHost,
                          magazineId,
                          title: _titleTextController.text,
                          image: _imageFile!,
                          alt: "",
                          isOc: _isOc,
                          body: _bodyTextController.text,
                          lang: 'en',
                          isAdult: _isAdult,
                          tags: tags,
                        );
                      }
                    } else {
                      await api_entries.createLink(
                        client,
                        instanceHost,
                        magazineId,
                        title: _titleTextController.text,
                        url: _urlTextController.text,
                        isOc: _isOc,
                        body: _bodyTextController.text,
                        lang: 'en',
                        isAdult: _isAdult,
                        tags: tags,
                      );
                    }
                  case CreateType.post:
                    await api_posts.createPost(
                      client,
                      instanceHost,
                      magazineId,
                      body: _bodyTextController.text,
                      lang: 'en',
                      isAdult: _isAdult,
                    );
                }

                // Check BuildContext
                if (!mounted) return;

                Navigator.pop(context);
              },
              icon: const Icon(Icons.send))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (widget.type != CreateType.post)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextEditor(
                      _titleTextController,
                      label: "Title",
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextEditor(
                    _bodyTextController,
                    isMarkdown: true,
                    label: "Body",
                  ),
                ),
                if (widget.type != CreateType.post)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextEditor(
                            _urlTextController,
                            keyboardType: TextInputType.url,
                            label: "URL",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: IconButton(
                            onPressed: () async {
                              XFile? image = await _imagePicker.pickImage(
                                  source: ImageSource.gallery
                              );
                              if (image != null) {
                                setState(() {
                                  _imageFile = File(image.path);
                                });
                              }
                            },
                            tooltip: 'Upload from gallery',
                            iconSize: 35,
                            icon: const Icon(Icons.image),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: IconButton(
                            onPressed: () async {
                              XFile? image = await _imagePicker.pickImage(
                                  source: ImageSource.camera
                              );
                              if (image != null) {
                                setState(() {
                                  _imageFile = File(image.path);
                                });
                              }
                            },
                            tooltip: 'Upload from camera',
                            iconSize: 35,
                            icon: const Icon(Icons.camera),
                          ),
                        )
                      ],
                    ),
                  ),
                if (widget.type != CreateType.post)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextEditor(
                      _tagsTextController,
                      label: "Tags",
                      hint: 'Separate with spaces',
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextEditor(
                    _magazineTextController..text = widget.magazineName ?? '',
                    label: 'Magazine',
                  ),
                ),
                if (widget.type != CreateType.post)
                  CheckboxListTile(
                    title: const Text('Original Content'),
                    value: _isOc,
                    onChanged: (newValue) => setState(() {
                      _isOc = newValue!;
                    }),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                CheckboxListTile(
                  title: const Text('NSFW'),
                  value: _isAdult,
                  onChanged: (newValue) => setState(() {
                    _isAdult = newValue!;
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
