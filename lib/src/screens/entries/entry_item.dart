import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/action_bar.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:interstellar/src/widgets/video.dart';
import 'package:provider/provider.dart';

class EntryItem extends StatelessWidget {
  const EntryItem(
    this.item,
    this.onUpdate, {
    super.key,
    this.isPreview = false,
    this.onReply,
  });

  final api_entries.EntryItem item;
  final void Function(api_entries.EntryItem) onUpdate;
  final Future<void> Function(String)? onReply;
  final bool isPreview;

  _onImageClick(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(item.title),
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
    final isVideo = item.url != null && isSupportedVideo(item.url!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!isPreview && isVideo) VideoPlayer(Uri.parse(item.url!)),
        if (item.image?.storageUrl != null && !(!isPreview && isVideo))
          isPreview
              ? (isVideo
                  ? Image.network(
                      item.image!.storageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : InkWell(
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
              item.url != null
                  ? InkWell(
                      child: Text(
                        item.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .apply(decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        openWebpage(context, Uri.parse(item.url!));
                      },
                    )
                  : Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              const SizedBox(height: 10),
              Row(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      timeDiffFormat(item.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                  DisplayName(
                    item.user.username,
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
                    child: IconButton(
                      tooltip: item.domain.name,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DomainScreen(
                              item.domain.domainId,
                              data: item.domain,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.public),
                      iconSize: 16,
                      style: const ButtonStyle(
                          minimumSize:
                              MaterialStatePropertyAll(Size.fromRadius(16))),
                    ),
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
                  onUpdate(await api_entries.putVote(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    item.entryId,
                    1,
                  ));
                }),
                onUpVote: whenLoggedIn(context, () async {
                  onUpdate(await api_entries.putFavorite(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    item.entryId,
                  ));
                }),
                onDownVote: whenLoggedIn(context, () async {
                  onUpdate(await api_entries.putVote(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    item.entryId,
                    -1,
                  ));
                }),
                onReply: onReply,
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
