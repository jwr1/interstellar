import 'package:flutter/material.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item/content_item.dart';
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
      originInstance: getNameHost(context, item.user.name),
      title: item.title,
      image: item.image,
      link: item.url != null ? Uri.parse(item.url!) : null,
      body: item.body,
      createdAt: item.createdAt,
      editedAt: item.editedAt,
      isPreview: isPreview,
      showMagazineFirst: item.type == PostType.thread,
      isPinned: item.isPinned,
      isNSFW: item.isNSFW,
      isOC: item.isOC == true,
      user: item.user.name,
      userIcon: item.user.avatar,
      userIdOnClick: item.user.id,
      userCakeDay: item.user.createdAt,
      userIsBot: item.user.isBot ?? false,
      magazine: item.magazine.name,
      magazineIcon: item.magazine.icon,
      magazineIdOnClick: item.magazine.id,
      domain: item.domain?.name,
      domainIdOnClick: item.domain?.id,
      boosts: item.boosts,
      isBoosted: item.myBoost == true,
      onBoost: whenLoggedIn(context, () async {
        onUpdate(await switch (item.type) {
          PostType.thread =>
            context.read<SettingsController>().api.threads.boost(item.id),
          PostType.microblog => context
              .read<SettingsController>()
              .api
              .microblogs
              .putVote(item.id, 1),
        });
      }),
      upVotes: item.upvotes,
      isUpVoted: item.myVote == 1,
      onUpVote: whenLoggedIn(context, () async {
        onUpdate(await switch (item.type) {
          PostType.thread => context
              .read<SettingsController>()
              .api
              .threads
              .vote(item.id, 1, item.myVote == 1 ? 0 : 1),
          PostType.microblog => context
              .read<SettingsController>()
              .api
              .microblogs
              .putFavorite(item.id),
        });
      }),
      downVotes: item.downvotes,
      isDownVoted: item.myVote == -1,
      onDownVote: whenLoggedIn(context, () async {
        onUpdate(await switch (item.type) {
          PostType.thread => context
              .read<SettingsController>()
              .api
              .threads
              .vote(item.id, -1, item.myVote == -1 ? 0 : -1),
          PostType.microblog => context
              .read<SettingsController>()
              .api
              .microblogs
              .putVote(item.id, -1),
        });
      }),
      contentTypeName: 'Post',
      onReply: onReply,
      onReport: whenLoggedIn(context, (reason) async {
        await switch (item.type) {
          PostType.thread => context
              .read<SettingsController>()
              .api
              .threads
              .report(item.id, reason),
          PostType.microblog => context
              .read<SettingsController>()
              .api
              .microblogs
              .report(item.id, reason),
        };
      }),
      onEdit: onEdit,
      onDelete: onDelete,
      numComments: item.numComments,
      openLinkUri: Uri.https(
        context.watch<SettingsController>().instanceHost,
        context.watch<SettingsController>().serverSoftware ==
                ServerSoftware.lemmy
            ? '/post/${item.id}'
            : '/m/${item.magazine.name}/${switch (item.type) {
                PostType.thread => 't',
                PostType.microblog => 'p',
              }}/${item.id}',
      ),
    );
  }
}
