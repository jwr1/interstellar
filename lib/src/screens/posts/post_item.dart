import 'package:flutter/material.dart';
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item.dart';
import 'package:provider/provider.dart';

class PostItem extends StatelessWidget {
  const PostItem(
    this.item,
    this.onUpdate, {
    super.key,
    this.isPreview = false,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  final PostModel item;
  final void Function(PostModel) onUpdate;
  final Future<void> Function(String)? onReply;
  final Future<void> Function(String)? onEdit;
  final Future<void> Function()? onDelete;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return ContentItem(
      body: item.body,
      image: item.image?.storageUrl,
      createdAt: item.createdAt,
      user: item.user.username,
      userIcon: item.user.avatar?.storageUrl,
      userIdOnClick: item.user.userId,
      magazine: item.magazine.name,
      magazineIcon: item.magazine.icon?.storageUrl,
      magazineIdOnClick: item.magazine.magazineId,
      boosts: item.uv,
      isBoosted: item.userVote == 1,
      onBoost: whenLoggedIn(context, () async {
        onUpdate(await api_posts.putVote(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          item.postId,
          1,
        ));
      }),
      upVotes: item.favourites,
      isUpVoted: item.isFavourited == true,
      onUpVote: whenLoggedIn(context, () async {
        onUpdate(await api_posts.putFavorite(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          item.postId,
        ));
      }),
      downVotes: item.dv,
      isDownVoted: item.userVote == -1,
      onDownVote: whenLoggedIn(context, () async {
        onUpdate(await api_posts.putVote(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          item.postId,
          -1,
        ));
      }),
      onReply: onReply,
      onEdit: onEdit,
      onDelete: onDelete,
      numComments: item.comments,
    );
  }
}
