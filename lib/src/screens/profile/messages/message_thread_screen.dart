import 'dart:math';

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
import 'package:material_symbols_icons/symbols.dart';
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
    if (_data == null) return const LoadingTemplate();

    final data = _data!;

    final myUsername =
        context.watch<SettingsController>().selectedAccount.split('@').first;

    final messageUser = data.participants.firstWhere(
      (user) => user.name != myUsername,
      orElse: () => data.participants.first,
    );

    final messageDraftController = context.watch<DraftsController>().auto(
        'message:${context.watch<SettingsController>().instanceHost}:${messageUser.name}');

    return Scaffold(
      appBar: AppBar(title: Text(messageUser.name)),
      body: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.all(16),
        itemCount: data.messages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(children: [
              const SizedBox(height: 8),
              MarkdownEditor(
                _controller,
                originInstance: null,
                draftController: messageDraftController,
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
                      icon: const Icon(Symbols.send_rounded))
                ],
              )
            ]);
          }

          final realIndex = index - 1;

          final nextMessage = realIndex - 1 < 0
              ? null
              : data.messages.elementAtOrNull(realIndex - 1);
          final currMessage = data.messages[realIndex];
          final prevMessage = realIndex + 1 >= data.messages.length
              ? null
              : data.messages.elementAt(realIndex + 1);

          final isMyUser = currMessage.sender.name == myUsername;

          final showDate = prevMessage == null ||
              !DateUtils.isSameDay(
                  currMessage.createdAt, prevMessage.createdAt);
          final showTime = prevMessage == null ||
              currMessage.createdAt
                      .difference(prevMessage.createdAt)
                      .inMinutes >
                  15;

          final showName =
              showTime || currMessage.sender.name != prevMessage.sender.name;

          const defaultRadius = Radius.circular(20);
          const connectedRadius = Radius.circular(4);

          final topRadius = showName ? defaultRadius : connectedRadius;
          final bottomRadius = nextMessage == null ||
                  currMessage.sender.name != nextMessage.sender.name ||
                  nextMessage.createdAt
                          .difference(currMessage.createdAt)
                          .inMinutes >
                      15
              ? defaultRadius
              : connectedRadius;

          return LayoutBuilder(builder: (context, constraints) {
            return Column(
              crossAxisAlignment:
                  isMyUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDate)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(DateUtils.isSameDay(
                                  currMessage.createdAt, DateTime.now())
                              ? 'Today'
                              : dateOnlyFormat(currMessage.createdAt)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),
                if (showTime || showName)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: reverseList([
                        const Spacer(),
                        if (showTime)
                          Text(
                            timeOnlyFormat(currMessage.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        if (showName)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: isMyUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                DisplayName(
                                  currMessage.sender.name,
                                  icon: currMessage.sender.avatar,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserScreen(currMessage.sender.id),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ], !isMyUser),
                    ),
                  ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: max(constraints.maxWidth * (2 / 3),
                          min(constraints.maxWidth - 32, 600))),
                  child: Card(
                    color:
                        isMyUser ? Theme.of(context).colorScheme.primary : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: isMyUser ? defaultRadius : topRadius,
                        topRight: isMyUser ? topRadius : defaultRadius,
                        bottomLeft: isMyUser ? defaultRadius : bottomRadius,
                        bottomRight: isMyUser ? bottomRadius : defaultRadius,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Markdown(
                        currMessage.body,
                        context.read<SettingsController>().instanceHost,
                        themeData: Theme.of(context).copyWith(
                          textTheme: isMyUser
                              ? Theme.of(context).primaryTextTheme
                              : Theme.of(context).textTheme,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
