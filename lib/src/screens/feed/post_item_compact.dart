import 'package:flutter/material.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/widgets/content_item/content_item_compact_post.dart';
import 'package:provider/provider.dart';
import 'package:interstellar/src/api/bookmark.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/ban_dialog.dart';

class PostItemCompact extends StatelessWidget {
  const PostItemCompact(
    this.item,
    this.onUpdate, {
    this.onReply,
    this.filterListWarnings,
    this.userCanModerate = false,
    super.key,
  });

  final PostModel item;
  final void Function(PostModel) onUpdate;
  final Future<void> Function(String)? onReply;
  final Set<String>? filterListWarnings;
  final bool userCanModerate;

  @override
  Widget build(BuildContext context) {
    final ac = context.watch<AppController>();

    final canModerate = userCanModerate || (item.canAuthUserModerate ?? false);

    return ContentItemCompactPost(
      title: item.title ?? item.body,
      image: item.image,
      link: item.url != null ? Uri.parse(item.url!) : null,
      createdAt: item.createdAt,
      editedAt: item.editedAt,
      showMagazineFirst: item.type == PostType.thread,
      isPinned: item.isPinned,
      isNSFW: item.isNSFW,
      isOC: item.isOC == true,
      user: item.user.name,
      userIdOnClick: item.user.id,
      userCakeDay: item.user.createdAt,
      userIsBot: item.user.isBot,
      magazine: item.magazine.name,
      magazineIdOnClick: item.magazine.id,
      upVotes: item.upvotes,
      downVotes: item.downvotes,
      numComments: item.numComments,
      replyDraftResourceId:
          'reply:${item.type.name}:${ac.instanceHost}:${item.id}',
      filterListWarnings: filterListWarnings,
      activeBookmarkLists: item.bookmarks,
      onUpVote: whenLoggedIn(context, () async {
        onUpdate(await switch (item.type) {
          PostType.thread =>
              ac.api.threads.vote(item.id, 1, item.myVote == 1 ? 0 : 1),
          PostType.microblog => ac.api.microblogs.putFavorite(item.id),
        });
      }),
      onDownVote: whenLoggedIn(context, () async {
        onUpdate(await switch (item.type) {
          PostType.thread =>
              ac.api.threads.vote(item.id, -1, item.myVote == -1 ? 0 : -1),
          PostType.microblog => ac.api.microblogs.putVote(item.id, -1),
        });
      }),
      onBoost: whenLoggedIn(context, () async {
        onUpdate(await switch (item.type) {
          PostType.thread => ac.api.threads.boost(item.id),
          PostType.microblog => ac.api.microblogs.putVote(item.id, 1),
        });
      }),
      onAddBookmark: whenLoggedIn(context, () async {
        final newBookmarks = await ac.api.bookmark.addBookmarkToDefault(
          subjectType: BookmarkListSubject.fromPostType(
              postType: item.type, isComment: false),
          subjectId: item.id,
        );
        onUpdate(item.copyWith(bookmarks: newBookmarks));
      }),
      onRemoveBookmark: whenLoggedIn(context, () async {
        final newBookmarks = await ac.api.bookmark.removeBookmarkFromAll(
          subjectType: BookmarkListSubject.fromPostType(
              postType: item.type, isComment: false),
          subjectId: item.id,
        );
        onUpdate(item.copyWith(bookmarks: newBookmarks));
      }),
      onReply: onReply,
      onModeratePin: !canModerate
          ? null
          : () async {
        onUpdate(await ac.api.moderation.postPin(item.type, item.id));
      },
      onModerateMarkNSFW: !canModerate
          ? null
          : () async {
        onUpdate(await ac.api.moderation
            .postMarkNSFW(item.type, item.id, !item.isNSFW));
      },
      onModerateDelete: !canModerate
          ? null
          : () async {
        onUpdate(
            await ac.api.moderation.postDelete(item.type, item.id, true));
      },
      onModerateBan: !canModerate
          ? null
          : () async {
        await openBanDialog(context,
            user: item.user, magazine: item.magazine);
      },
    );
  }
}
