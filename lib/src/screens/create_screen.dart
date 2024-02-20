import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/language_codes.dart';
import 'package:interstellar/src/widgets/image_selector.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

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
  XFile? _imageFile;
  String _lang = '';

  @override
  void initState() {
    super.initState();

    _lang = context.read<SettingsController>().defaultCreateLang;
    _magazineTextController.text = widget.magazineName ?? '';
  }

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
                final api = context.read<SettingsController>().api;

                var magazineName = _magazineTextController.text;

                int? magazineId = widget.magazineId;
                if (magazineId == null) {
                  final magazine = await api.magazines.getByName(magazineName);
                  magazineId = magazine.id;
                }

                var tags = _tagsTextController.text.isNotEmpty
                    ? _tagsTextController.text.split(' ')
                    : <String>[];

                switch (widget.type) {
                  case CreateType.entry:
                    if (_urlTextController.text.isEmpty) {
                      if (_imageFile == null) {
                        await api.entries.createArticle(
                          magazineId,
                          title: _titleTextController.text,
                          isOc: _isOc,
                          body: _bodyTextController.text,
                          lang: _lang,
                          isAdult: _isAdult,
                          tags: tags,
                        );
                      } else {
                        await api.entries.createImage(
                          magazineId,
                          title: _titleTextController.text,
                          image: _imageFile!,
                          alt: "",
                          isOc: _isOc,
                          body: _bodyTextController.text,
                          lang: _lang,
                          isAdult: _isAdult,
                          tags: tags,
                        );
                      }
                    } else {
                      await api.entries.createLink(
                        magazineId,
                        title: _titleTextController.text,
                        url: _urlTextController.text,
                        isOc: _isOc,
                        body: _bodyTextController.text,
                        lang: _lang,
                        isAdult: _isAdult,
                        tags: tags,
                      );
                    }
                  case CreateType.post:
                    if (_imageFile == null) {
                      await api.posts.create(
                        magazineId,
                        body: _bodyTextController.text,
                        lang: _lang,
                        isAdult: _isAdult,
                      );
                    } else {
                      await api.posts.createImage(
                        magazineId,
                        image: _imageFile!,
                        alt: "",
                        body: _bodyTextController.text,
                        lang: _lang,
                        isAdult: _isAdult,
                      );
                    }
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
                if (_imageFile == null || widget.type == CreateType.post)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextEditor(
                      _bodyTextController,
                      isMarkdown: true,
                      label: "Body",
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                if (widget.type != CreateType.post)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        if (_imageFile == null)
                          Expanded(
                            child: TextEditor(
                              _urlTextController,
                              keyboardType: TextInputType.url,
                              label: "URL",
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ImageSelector(
                          _imageFile,
                          (file) => setState(() {
                            _imageFile = file;
                          }),
                          enabled: _bodyTextController.text.isEmpty &&
                              _urlTextController.text.isEmpty,
                        )
                      ],
                    ),
                  ),
                if (widget.type == CreateType.post)
                  ImageSelector(
                    _imageFile,
                    (file) => setState(() {
                      _imageFile = file;
                    }),
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
                    _magazineTextController,
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
                ListTile(
                  title: const Text('Language'),
                  onTap: () async {
                    final newLang =
                        await languageSelectionMenu.inquireSelection(
                      context,
                      _lang,
                    );

                    if (newLang != null) {
                      setState(() {
                        _lang = newLang;
                      });
                    }
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(getLangName(_lang))],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
