import 'package:flutter/material.dart';
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class MessageItem extends StatelessWidget {
  const MessageItem(this.item, this.onUpdate, {this.onClick, super.key});

  final MessageThreadModel item;
  final void Function(MessageThreadModel) onUpdate;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    final messageUser = item.participants
        .where((user) =>
            user.name !=
            context
                .watch<SettingsController>()
                .selectedAccount
                .split("@")
                .first)
        .first;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onClick,
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
                      messageUser.name,
                      icon: messageUser.avatar,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserScreen(messageUser.id),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Markdown(item.messages.first.body,
                    context.watch<SettingsController>().instanceHost),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
