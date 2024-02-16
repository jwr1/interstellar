import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/api/messages.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/feed_screen.dart';
import 'package:interstellar/src/screens/profile/message_thread_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/image_selector.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  final int userId;
  final DetailedUserModel? initData;
  final void Function(DetailedUserModel)? onUpdate;

  const UserScreen(this.userId, {super.key, this.initData, this.onUpdate});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  DetailedUserModel? _data;
  TextEditingController? _messageController;
  TextEditingController? _aboutTextController;
  XFile? _avatarFile;
  XFile? _coverFile;

  @override
  void initState() {
    super.initState();

    _data = widget.initData;

    if (_data == null) {
      api_users
          .fetchUser(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.userId,
          )
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeedScreen(
      source: FeedSourceUser(widget.userId),
      title: _data?.username ?? '',
      details: _data != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 3,
                      ),
                      height: _data!.cover == null ? 100 : null,
                      child: _data!.cover != null ? Image.network(
                        _data!.cover!.storageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Avatar(
                          _data!.avatar?.storageUrl,
                          radius: 32,
                          borderRadius: 4,
                        ),
                      )
                    ),
                    if (whenLoggedIn(context, true, matchesUsername: _data!.username) != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _aboutTextController == null
                            ? TextButton(
                                onPressed: () => setState(() {
                                  _aboutTextController = TextEditingController(
                                    text: _data!.about
                                  );
                                }),
                                child: const Text("Edit")
                              )
                            : Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  var user = await api_users.updateProfile(
                                    context.read<SettingsController>().httpClient,
                                    context.read<SettingsController>().instanceHost,
                                    _aboutTextController!.text
                                  );
                                  if (!mounted) return;
                                  if (_avatarFile != null) {
                                    user = await api_users.updateAvatar(
                                      context.read<SettingsController>().httpClient,
                                      context.read<SettingsController>().instanceHost,
                                      _avatarFile!
                                    );
                                  }
                                  if (!mounted) return;
                                  if (_coverFile != null) {
                                    user = await api_users.updateCover(
                                      context.read<SettingsController>().httpClient,
                                      context.read<SettingsController>().instanceHost,
                                      _coverFile!
                                    );
                                  }

                                  setState(() {
                                    _data = user;
                                    _aboutTextController!.dispose();
                                    _aboutTextController = null;
                                    _coverFile = null;
                                    _avatarFile = null;
                                  });
                                },
                                child: const Text("Save")
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _aboutTextController!.dispose();
                                    _aboutTextController = null;
                                  });
                                },
                                child: const Text("Cancel")
                              ),
                            ],
                          ),
                        )
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _data!.username.contains('@')
                                    ? _data!.username.split('@')[1]
                                    : _data!.username,
                                style: Theme.of(context).textTheme.titleLarge,
                                softWrap: true,
                              ),
                              InkWell(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                        text: _data!.username.contains('@')
                                            ? _data!.username
                                            : '@${_data!.username}@${context.read<SettingsController>().instanceHost}'),
                                  );

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Copied')));
                                },
                                child: Text(
                                  _data!.username.contains('@')
                                      ? _data!.username
                                      : '@${_data!.username}@${context.read<SettingsController>().instanceHost}',
                                  softWrap: true,
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll(
                                      _data!.isFollowedByUser == true
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : null),
                                ),
                                onPressed: whenLoggedIn(context, () async {
                                  var newValue = await api_users.putFollow(
                                      context
                                          .read<SettingsController>()
                                          .httpClient,
                                      context
                                          .read<SettingsController>()
                                          .instanceHost,
                                      _data!.userId,
                                      !_data!.isFollowedByUser!);
                                  setState(() {
                                    _data = newValue;
                                  });
                                  if (widget.onUpdate != null) {
                                    widget.onUpdate!(newValue);
                                  }
                                }),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.group),
                                    Text(
                                        ' ${intFormat(_data!.followersCount)}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (whenLoggedIn(context, true) == true)
                            IconButton(
                              onPressed: () async {
                                final newValue = await api_users.putBlock(
                                  context.read<SettingsController>().httpClient,
                                  context
                                      .read<SettingsController>()
                                      .instanceHost,
                                  _data!.userId,
                                  !_data!.isBlockedByUser!,
                                );

                                setState(() {
                                  _data = newValue;
                                });
                                if (widget.onUpdate != null) {
                                  widget.onUpdate!(newValue);
                                }
                              },
                              icon: const Icon(Icons.block),
                              style: ButtonStyle(
                                foregroundColor: MaterialStatePropertyAll(
                                    _data!.isBlockedByUser == true
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).disabledColor),
                              ),
                            ),
                          if (!_data!.username.contains('@'))
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _messageController = TextEditingController();
                                });
                              },
                              icon: const Icon(Icons.mail),
                              tooltip: 'Send message',
                            )
                        ],
                      ),
                      if (_messageController != null)
                        Column(children: [
                          TextEditor(
                            _messageController!,
                            isMarkdown: true,
                            label: 'Message',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  setState(() {
                                    _messageController = null;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  final newThread = await postMessage(
                                    context
                                        .read<SettingsController>()
                                        .httpClient,
                                    context
                                        .read<SettingsController>()
                                        .instanceHost,
                                    _data!.userId,
                                    _messageController!.text,
                                  );

                                  setState(() {
                                    _messageController = null;

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MessageThreadScreen(
                                          initData: newThread,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                child: const Text('Send'),
                              )
                            ],
                          )
                        ]),
                      if (_data!.about != null || _aboutTextController != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _aboutTextController == null
                              ? Markdown(
                                _data!.about!,
                                getNameHost(context, _data!.username),
                              )
                              : TextEditor(
                                _aboutTextController!,
                                label: "About",
                                isMarkdown: true,
                              )
                        ),
                      if (_aboutTextController != null)
                        Row(
                          children: [
                            const Text("Select Avatar"),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: ImageSelector(
                                _avatarFile,
                                (file) => setState(() {
                                  _avatarFile = file;
                                })
                              ),
                            )
                          ],
                        ),
                      if (_aboutTextController != null)
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
                    ],
                  ),
                )
              ],
            )
          : null,
    );
  }
}
