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
    final settings = await context.read<SettingsController>().api.users.getUserSettings();
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
                  _settings = await context.read<SettingsController>().api.users.saveUserSettings(_settings!);
                }
                if (!context.mounted) return;

                var user = await context.read<SettingsController>().api.users
                    .updateProfile(_aboutTextController!.text);

                if (!context.mounted) return;
                if (_deleteAvatar) {
                  user = await context.read<SettingsController>().api.users
                      .deleteAvatar();
                }
                if (!context.mounted) return;
                if (_deleteCover) {
                  user = await context.read<SettingsController>().api.users
                      .deleteCover();
                }

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
                      ),
                      TextButton(
                          onPressed: () {
                            _deleteAvatar = true;
                          },
                          child: const Text("Delete")
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
                          _deleteCover = true;
                        },
                        child: const Text("Delete"),
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
                  ),
                  if (_settings != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Settings",
                          style: Theme.of(context).textTheme.titleLarge
                        ),
                        Row(
                          children: [
                            const Text("Show NSFW"),
                            const Spacer(),
                            Switch(
                              value: _settings!.showNSFW,
                              onChanged: (bool? value) {
                                setState(() {
                                  _settings!.showNSFW = value!;
                                  _settingsChanged = true;
                                });
                              }
                            )
                          ],
                        ),
                        if (_settings!.blurNSFW != null)
                          Row(
                            children: [
                              const Text("Blur NSFW"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.blurNSFW!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.blurNSFW = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showReadPosts != null)
                          Row(
                            children: [
                              const Text("Show read posts"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showReadPosts!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showReadPosts = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showSubscribedUsers != null)
                          Row(
                            children: [
                              const Text("Show subscribed users"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showSubscribedUsers!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showSubscribedUsers = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showSubscribedUsers != null)
                          Row(
                            children: [
                              const Text("Show subscribed users"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showSubscribedUsers!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showSubscribedUsers = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showSubscribedMagazines != null)
                          Row(
                            children: [
                              const Text("Show subscribed magazines"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showSubscribedMagazines!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showSubscribedMagazines = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showSubscribedDomains != null)
                          Row(
                            children: [
                              const Text("Show subscribed domains"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showSubscribedDomains!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showSubscribedDomains = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showProfileSubscriptions != null)
                          Row(
                            children: [
                              const Text("Show profile subscriptions"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showProfileSubscriptions!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showProfileSubscriptions = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.showProfileFollowings != null)
                          Row(
                            children: [
                              const Text("Show profile followings"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.showProfileFollowings!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.showProfileFollowings = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.notifyOnNewEntry != null)
                          Row(
                            children: [
                              const Text("Notify on new threads in subscribed magazines"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.notifyOnNewEntry!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.notifyOnNewEntry = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.notifyOnNewPost != null)
                          Row(
                            children: [
                              const Text("Notify on new micropost in subscribed magazines"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.notifyOnNewPost!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.notifyOnNewPost = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.notifyOnNewEntryReply != null)
                          Row(
                            children: [
                              const Text("Notify on comments in authored threads"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.notifyOnNewEntryReply!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.notifyOnNewEntryReply = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.notifyOnNewEntryCommentReply != null)
                          Row(
                            children: [
                              const Text("Notify on thread comment reply"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.notifyOnNewEntryCommentReply!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.notifyOnNewEntryCommentReply = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.notifyOnNewPostReply != null)
                          Row(
                            children: [
                              const Text("Notify on comments in authored microposts"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.notifyOnNewPostReply!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.notifyOnNewPostReply = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                        if (_settings!.notifyOnNewPostCommentReply != null)
                          Row(
                            children: [
                              const Text("Notify on micropost comment reply"),
                              const Spacer(),
                              Switch(
                                  value: _settings!.notifyOnNewPostCommentReply!,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _settings!.notifyOnNewPostCommentReply = value!;
                                      _settingsChanged = true;
                                    });
                                  }
                              )
                            ],
                          ),
                      ],
                    )
                  )
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}