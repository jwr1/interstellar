import 'package:flutter/material.dart';
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
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
                .split('@')
                .first)
        .first;

    return ListTile(
      title: Text(messageUser.name),
      subtitle: Text(
        item.messages.first.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Avatar(messageUser.avatar),
      trailing: Text('${dateDiffFormat(item.messages.first.createdAt)} ago'),
      onTap: onClick,
    );
  }
}
