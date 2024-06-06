import 'package:flutter/material.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/cake_day_icon.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
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
                if (isSameDayOfYear(user.createdAt))
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: CakeDayIcon(),
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
