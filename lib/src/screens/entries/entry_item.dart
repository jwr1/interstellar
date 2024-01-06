import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/models/entry.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item.dart';
import 'package:interstellar/src/widgets/video.dart';
import 'package:provider/provider.dart';

class EntryItem extends StatelessWidget {
  const EntryItem(
    this.item,
    this.onUpdate, {
    super.key,
    this.isPreview = false,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  final EntryModel item;
  final void Function(EntryModel) onUpdate;
  final Future<void> Function(String)? onReply;
  final Future<void> Function(String)? onEdit;
  final Future<void> Function()? onDelete;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.url != null && isSupportedVideo(item.url!);

    return ContentItem(
      title: item.title,
      image: item.image?.storageUrl,
      link: item.url != null ? Uri.parse(item.url!) : null,
      video: isVideo ? Uri.parse(item.url!) : null,
      body: item.body,
      createdAt: item.createdAt,
      isPreview: isPreview,
      showMagazineFirst: true,
      user: item.user.username,
      userIcon: item.user.avatar?.storageUrl,
      userIdOnClick: item.user.userId,
      magazine: item.magazine.name,
      magazineIcon: item.magazine.icon?.storageUrl,
      magazineIdOnClick: item.magazine.magazineId,
      domain: item.domain.name,
      domainIdOnClick: item.domain.domainId,
      boosts: item.uv,
      isBoosted: item.userVote == 1,
      onBoost: whenLoggedIn(context, () async {
        onUpdate(await api_entries.putVote(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          item.entryId,
          1,
        ));
      }),
      upVotes: item.favourites,
      isUpVoted: item.isFavourited == true,
      onUpVote: whenLoggedIn(context, () async {
        onUpdate(await api_entries.putFavorite(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          item.entryId,
        ));
      }),
      downVotes: item.dv,
      isDownVoted: item.userVote == -1,
      onDownVote: whenLoggedIn(context, () async {
        onUpdate(await api_entries.putVote(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          item.entryId,
          -1,
        ));
      }),
      onReply: onReply,
      onEdit: onEdit,
      onDelete: onDelete,
      numComments: item.numComments,
    );
  }
}
