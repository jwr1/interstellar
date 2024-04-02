import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

import '../../widgets/avatar.dart';
import '../../widgets/image_selector.dart';
import '../settings/settings_controller.dart';

class ProfileEditScreen extends StatefulWidget {

  final DetailedUserModel user;
  final void Function(DetailedUserModel?) onUpdate;

  const ProfileEditScreen(this.user, this.onUpdate, {super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreen();
}

class _ProfileEditScreen extends State<ProfileEditScreen> {

  TextEditingController? _aboutTextController;
  XFile? _avatarFile;
  XFile? _coverFile;

  @override
  void initState() {
    super.initState();

    _aboutTextController = TextEditingController(text: widget.user.about);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                var user = await context.read<SettingsController>().api.users
                    .updateProfile(_aboutTextController!.text);

                if (!context.mounted) return;
                if (_avatarFile != null) {
                  user = await context.read<SettingsController>().api.users
                      .updateAvatar(_avatarFile!);
                }
                if (!context.mounted) return;
                if (_coverFile != null) {
                  user = await context.read<SettingsController>().api.users
                      .updateCover(_coverFile!);
                }
                if (!context.mounted) return;

                widget.onUpdate(user);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.start)
          )
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 3,
                ),
                height: widget.user.cover == null ? 100 : null,
                child: _coverFile != null
                    ? Image.file(File(_coverFile!.path))
                    : widget.user.cover != null
                      ? Image.network(
                        widget.user.cover!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : null,
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Avatar(
                    widget.user.avatar,
                    radius: 32,
                    borderRadius: 4,
                  ),
                ),
              ),
            ]
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.displayName ??
                                widget.user.name.split('@').first,
                            style:
                            Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            widget.user.name.contains('@')
                                  ? '@${widget.user.name}'
                                  : '@${widget.user.name}@${context.read<SettingsController>().instanceHost}',
                            ),
                        ],
                      ),
                    ),
                  ]
                ),
                Row(
                  children: [
                    const Text("Select Avatar"),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ImageSelector(
                        _avatarFile,
                            (file) => setState(() {
                          _avatarFile = file;
                        })),
                    )
                  ],
                ),
                Row(
                  children: [
                    const Text("Select Cover"),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ImageSelector(
                        _coverFile,
                            (file) => setState(() {
                          _coverFile = file;
                        }),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextEditor(
                    _aboutTextController!,
                    label: "About",
                    isMarkdown: true,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}