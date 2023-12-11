import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/entries/entry_page.dart';
import 'package:interstellar/src/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.item,
  });

  final api_entries.EntryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EntryPage(
                  item: item,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (item.image?.storageUrl != null)
                Image.network(
                  item.image!.storageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
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
                        Text(
                          extractMag(item.magazine.name),
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '  ${timeDiffFormat(item.createdAt)}  ',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w300),
                        ),
                        Text(
                          extractUser(item.user.username),
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (item.body != null && item.body!.isNotEmpty)
                      const SizedBox(height: 10),
                    if (item.body != null && item.body!.isNotEmpty)
                      Text(
                        item.body ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.comment),
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () {},
                        ),
                        Text(item.numComments.toString()),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () {},
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.rocket_launch),
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () {},
                        ),
                        Text(item.uv.toString()),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () {},
                        ),
                        Text((item.favourites - item.dv).toString()),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
