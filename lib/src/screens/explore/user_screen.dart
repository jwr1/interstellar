import 'package:flutter/material.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/api/messages.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/feed_screen.dart';
import 'package:interstellar/src/screens/profile/message_thread_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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
                alignment: Alignment.bottomLeft,
                children: [
                  if (_data!.cover != null)
                    Image.network(
                      _data!.cover!.storageUrl,
                      width: _data!.cover!.width.toDouble(),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Avatar(_data!.avatar?.storageUrl, radius: 32, borderRadius: 5,),
                  ),
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
                              _data!.username.contains('@') ? _data!.username.split('@')[1] : _data!.username,
                              style: Theme.of(context).textTheme.titleLarge,
                              softWrap: true,
                            ),
                            InkWell(
                              onTap: () async {
                                await Clipboard.setData(ClipboardData(text: _data!.username.contains('@')
                                    ? _data!.username
                                    : '@${_data!.username}@${context.read<SettingsController>().instanceHost}'));
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
                                foregroundColor: _data!.isFollowedByUser == true
                                    ? null
                                    : MaterialStatePropertyAll(
                                      Theme.of(context).disabledColor
                                    )
                              ),
                              onPressed: whenLoggedIn(context, () async {
                                var newValue = await api_users.putFollow(
                                  context.read<SettingsController>().httpClient,
                                  context.read<SettingsController>().instanceHost,
                                  _data!.userId,
                                  !_data!.isFollowedByUser!
                                );
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
                                  Text(' ${intFormat(_data!.followersCount)}'),
                                ],
                              ),
                            )
                          )
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
                                  context.read<SettingsController>().httpClient,
                                  context.read<SettingsController>().instanceHost,
                                  _data!.userId,
                                  _messageController!.text,
                                );

                                setState(() {
                                  _messageController = null;

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MessageThreadScreen(
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
                    if (_data!.about != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Markdown(_data!.about!),
                      )
                  ],
                ),
              )
            ]
          )
        : null
    );
  }
}
