import 'package:flutter/material.dart';
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/action_bar.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
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

  final api_posts.PostItem item;
  final void Function(api_posts.PostItem) onUpdate;
  final Future<void> Function(String)? onReply;
  final Future<void> Function(String)? onEdit;
  final Future<void> Function()? onDelete;
  final bool isPreview;

  _onImageClick(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(item.user.username),
            backgroundColor: const Color(0x66000000),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    item.image!.storageUrl,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (item.image?.storageUrl != null)
          isPreview
              ? (InkWell(
                  onTap: () => _onImageClick(context),
                  child: Image.network(
                    item.image!.storageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ))
              : Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: InkWell(
                    onTap: () => _onImageClick(context),
                    child: Image.network(
                      item.image!.storageUrl,
                    ),
                  )),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                children: [
                  DisplayName(
                    item.user.username,
                    icon: item.user.avatar?.storageUrl,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserScreen(item.user.userId),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      timeDiffFormat(item.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                  DisplayName(
                    item.magazine.name,
                    icon: item.magazine.icon?.storageUrl,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MagazineScreen(
                            item.magazine.magazineId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (item.body != null && item.body!.isNotEmpty)
                const SizedBox(height: 10),
              if (item.body != null && item.body!.isNotEmpty)
                isPreview
                    ? Text(
                        item.body!,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Markdown(item.body!),
              const SizedBox(height: 10),
              ActionBar(
                boosts: item.uv,
                upVotes: item.favourites,
                downVotes: item.dv,
                isBoosted: item.userVote == 1,
                isUpVoted: item.isFavourited == true,
                isDownVoted: item.userVote == -1,
                onBoost: whenLoggedIn(context, () async {
                  onUpdate(await api_posts.putVote(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    item.postId,
                    1,
                  ));
                }),
                onUpVote: whenLoggedIn(context, () async {
                  onUpdate(await api_posts.putFavorite(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    item.postId,
                  ));
                }),
                onDownVote: whenLoggedIn(context, () async {
                  onUpdate(await api_posts.putVote(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    item.postId,
                    -1,
                  ));
                }),
                onReply: onReply,
                onEdit: whenLoggedIn(
                  context,
                  onEdit,
                  matchesUsername: item.user.username,
                ),
                onDelete: whenLoggedIn(
                  context,
                  onDelete,
                  matchesUsername: item.user.username,
                ),
                initEdit: () {
                  return item.body;
                },
                leadingWidgets: [
                  const Icon(Icons.comment),
                  const SizedBox(width: 4),
                  Text(intFormat(item.numComments)),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
