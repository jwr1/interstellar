import 'package:flutter/material.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/widgets/content_item/content_item_compact_post.dart';

class PostItemCompact extends StatelessWidget {
  const PostItemCompact(
    this.item, {
    this.filterListWarnings,
    super.key,
  });

  final PostModel item;
  final Set<String>? filterListWarnings;

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
