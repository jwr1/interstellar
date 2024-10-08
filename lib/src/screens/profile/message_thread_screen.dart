import 'package:flutter/material.dart';
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/loading_template.dart';
import 'package:interstellar/src/widgets/markdown/drafts_controller.dart';
import 'package:interstellar/src/widgets/markdown/markdown.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';
import 'package:provider/provider.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({
    this.initData,
    this.onUpdate,
    super.key,
  });

  final MessageThreadModel? initData;
  final void Function(MessageThreadModel)? onUpdate;

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  MessageThreadModel? _data;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _data = widget.initData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const LoadingTemplate();
    }

    final data = _data!;

    final messageUser = data.participants
        .where((user) =>
            user.name !=
            context
                .watch<SettingsController>()
                .selectedAccount
                .split('@')
                .first)
        .first;

    final messageDraftController = context.watch<DraftsController>().auto(
        'message:${context.watch<SettingsController>().instanceHost}:${messageUser.name}');

    return Scaffold(
      appBar: AppBar(title: Text(l(context).messagesWith(messageUser.name))),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            MarkdownEditor(
              _controller,
              originInstance: null,
              draftController: messageDraftController,
              label: l(context).reply,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LoadingFilledButton(
                  onPressed: () async {
                    final newThread = await context
                        .read<SettingsController>()
                        .api
                        .messages
                        .postThreadReply(
                          data.threadId,
                          _controller.text,
                        );

                    await messageDraftController.discard();

                    _controller.text = '';

                    setState(() {
                      _data = newThread;
                    });

                    if (widget.onUpdate != null) {
                      widget.onUpdate!(newThread);
                    }
                  },
                  label: Text(l(context).send),
                )
              ],
            )
          ]),
        ),
        ...data.messages.map(
          (message) => Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: DisplayName(
                          message.sender.name,
                          icon: message.sender.avatar,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserScreen(message.sender.id),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Markdown(message.body,
                        context.read<SettingsController>().instanceHost),
                  ),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}
