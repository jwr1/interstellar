import 'package:flutter/material.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
import 'package:interstellar/src/widgets/user_status_icons.dart';
import 'package:provider/provider.dart';

class UserItem extends StatelessWidget {
  final DetailedUserModel user;
  final void Function(DetailedUserModel) onUpdate;

  const UserItem(this.user, this.onUpdate, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserScreen(
              user.id,
              initData: user,
              onUpdate: onUpdate,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          if (user.avatar != null)
            Avatar(
              user.avatar,
              radius: 16,
            ),
          Container(width: 8 + (user.avatar != null ? 0 : 32)),
          Expanded(
            child: Row(
              children: [
                Flexible(
                    child: Text(user.name, overflow: TextOverflow.ellipsis)),
                UserStatusIcons(
                  cakeDay: user.createdAt,
                  isBot: user.isBot,
                ),
              ],
            ),
          ),
          if (user.followersCount != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: SubscriptionButton(
                subsCount: user.followersCount!,
                isSubed: user.isFollowedByUser == true,
                onPress: whenLoggedIn(context, () async {
                  onUpdate(await context
                      .read<SettingsController>()
                      .api
                      .users
                      .follow(user.id, !user.isFollowedByUser!));
                }),
              ),
            )
        ]),
      ),
    );
  }
}

class UserItemSimple extends StatelessWidget {
  final UserModel user;
  final bool isOwner;
  final List<Widget>? trailingWidgets;
  final bool noTap;

  const UserItemSimple(
    this.user, {
    this.isOwner = false,
    this.trailingWidgets,
    this.noTap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserScreen(user.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          if (user.avatar != null)
            Avatar(
              user.avatar,
              radius: 16,
            ),
          Container(width: 8 + (user.avatar != null ? 0 : 32)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontWeight: isOwner ? FontWeight.bold : null),
                ),
                if (isOwner) Text(l(context).owner),
              ],
            ),
          ),
          ...trailingWidgets ?? []
        ]),
      ),
    );
  }
}
