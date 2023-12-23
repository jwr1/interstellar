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
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (item.image?.storageUrl != null)
          isPreview
              ? Image.network(
                  item.image!.storageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: Image.network(
                    item.image!.storageUrl,
                  )),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              item.type == 'link' && item.url != null
                  ? InkWell(
                      child: Text(
                        item.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .apply(decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        launchUrl(Uri.parse(item.url!));
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
