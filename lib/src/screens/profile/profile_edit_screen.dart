import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/widgets/image.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';
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
  bool _deleteAvatar = false;
  XFile? _coverFile;
  bool _deleteCover = false;
  UserSettings? _settings;
  bool _settingsChanged = false;

  @override
  void initState() {
    super.initState();

    _aboutTextController = TextEditingController(text: widget.user.about);
    _initSettings();
  }

  void _initSettings() async {
    final settings =
        await context.read<SettingsController>().api.users.getUserSettings();
    setState(() {
      _settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              if (_settingsChanged) {
                _settings = await context
                    .read<SettingsController>()
                    .api
                    .users
                    .saveUserSettings(_settings!);
              }
              if (!context.mounted) return;

              var user = await context
                  .read<SettingsController>()
                  .api
                  .users
                  .updateProfile(_aboutTextController!.text);

              if (!context.mounted) return;
              if (_deleteAvatar) {
                user = await context
                    .read<SettingsController>()
                    .api
                    .users
                    .deleteAvatar();
              }
              if (!context.mounted) return;
              if (_deleteCover) {
                user = await context
                    .read<SettingsController>()
                    .api
                    .users
                    .deleteCover();
              }

              if (!context.mounted) return;
              if (_avatarFile != null) {
                user = await context
                    .read<SettingsController>()
                    .api
                    .users
                    .updateAvatar(_avatarFile!);
              }
              if (!context.mounted) return;
              if (_coverFile != null) {
                user = await context
                    .read<SettingsController>()
                    .api
                    .users
                    .updateCover(_coverFile!);
              }
              if (!context.mounted) return;

              widget.onUpdate(user);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
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
                        ? _deleteCover
                            ? null
                            : AdvancedImage(
                                widget.user.cover!,
                                fit: BoxFit.fitWidth,
                              )
                        : null,
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Avatar(
                    _deleteAvatar ? null : widget.user.avatar,
                    radius: 32,
                    borderRadius: 4,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.displayName ??
                              widget.user.name.split('@').first,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          widget.user.name.contains('@')
                              ? '@${widget.user.name}'
                              : '@${widget.user.name}@${context.watch<SettingsController>().instanceHost}',
                        ),
                      ],
                    ),
                  ),
                ]),
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
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _deleteAvatar = true;
                        });
                      },
                      child: const Text("Delete"),
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
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _deleteCover = true;
                        });
                      },
                      child: const Text("Delete"),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: MarkdownEditor(
                    _aboutTextController!,
                    label: "About",
                  ),
                ),
                if (_settings != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Settings",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SwitchListTile(
                            title: const Text("Show NSFW"),
                            value: _settings!.showNSFW,
                            onChanged: (bool value) {
                              setState(() {
                                _settings!.showNSFW = value;
                                _settingsChanged = true;
                              });
                            },
                          ),
                          if (_settings!.blurNSFW != null)
                            SwitchListTile(
                              title: const Text("Blur NSFW"),
                              value: _settings!.blurNSFW!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.blurNSFW = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.showReadPosts != null)
                            SwitchListTile(
                              title: const Text("Show read posts"),
                              value: _settings!.showReadPosts!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showReadPosts = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.showSubscribedUsers != null)
                            SwitchListTile(
                              title: const Text("Show subscribed users"),
                              value: _settings!.showSubscribedUsers!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showSubscribedUsers = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.showSubscribedMagazines != null)
                            SwitchListTile(
                              title: const Text("Show subscribed magazines"),
                              value: _settings!.showSubscribedMagazines!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showSubscribedMagazines = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.showSubscribedDomains != null)
                            SwitchListTile(
                              title: const Text("Show subscribed domains"),
                              value: _settings!.showSubscribedDomains!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showSubscribedDomains = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.showProfileSubscriptions != null)
                            SwitchListTile(
                              title: const Text("Show profile subscriptions"),
                              value: _settings!.showProfileSubscriptions!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showProfileSubscriptions = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.showProfileFollowings != null)
                            SwitchListTile(
                              title: const Text("Show profile followings"),
                              value: _settings!.showProfileFollowings!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showProfileFollowings = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.notifyOnNewEntry != null)
                            SwitchListTile(
                              title: const Text(
                                  "Notify on new threads in subscribed magazines"),
                              value: _settings!.notifyOnNewEntry!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.notifyOnNewEntry = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.notifyOnNewPost != null)
                            SwitchListTile(
                              title: const Text(
                                  "Notify on new microblog in subscribed magazines"),
                              value: _settings!.notifyOnNewPost!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.notifyOnNewPost = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.notifyOnNewEntryReply != null)
                            SwitchListTile(
                              title: const Text(
                                  "Notify on comments in authored threads"),
                              value: _settings!.notifyOnNewEntryReply!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.notifyOnNewEntryReply = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.notifyOnNewEntryCommentReply != null)
                            SwitchListTile(
                              title:
                                  const Text("Notify on thread comment reply"),
                              value: _settings!.notifyOnNewEntryCommentReply!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.notifyOnNewEntryCommentReply =
                                      value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.notifyOnNewPostReply != null)
                            SwitchListTile(
                              title: const Text(
                                  "Notify on comments in authored microposts"),
                              value: _settings!.notifyOnNewPostReply!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.notifyOnNewPostReply = value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                          if (_settings!.notifyOnNewPostCommentReply != null)
                            SwitchListTile(
                              title: const Text(
                                  "Notify on microblog comment reply"),
                              value: _settings!.notifyOnNewPostCommentReply!,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.notifyOnNewPostCommentReply =
                                      value!;
                                  _settingsChanged = true;
                                });
                              },
                            ),
                        ],
                      ))
              ],
            ),
          ),
        ],
      )),
    );
  }
}
