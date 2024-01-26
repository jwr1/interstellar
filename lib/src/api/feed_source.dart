enum FeedSort { active, hot, newest, oldest, top, commented }

abstract class FeedSource {
  String getEntriesPath();
  String? getPostsPath();
}

class FeedSourceAll implements FeedSource {
  const FeedSourceAll();

  @override
  String getEntriesPath() => '/api/entries';
  @override
  String getPostsPath() => '/api/posts';
}

class FeedSourceSub implements FeedSource {
  const FeedSourceSub();

  @override
  String getEntriesPath() => '/api/entries/subscribed';
  @override
  String getPostsPath() => '/api/posts/subscribed';
}

class FeedSourceMod implements FeedSource {
  const FeedSourceMod();

  @override
  String getEntriesPath() => '/api/entries/moderated';
  @override
  String getPostsPath() => '/api/posts/moderated';
}

class FeedSourceFav implements FeedSource {
  const FeedSourceFav();

  @override
  String getEntriesPath() => '/api/entries/favourited';
  @override
  String getPostsPath() => '/api/posts/favourited';
}

class FeedSourceMagazine implements FeedSource {
  final int id;

  const FeedSourceMagazine(this.id);

  @override
  String getEntriesPath() => '/api/magazine/$id/entries';
  @override
  String getPostsPath() => '/api/magazine/$id/posts';
}

class FeedSourceUser implements FeedSource {
  final int id;

  const FeedSourceUser(this.id);

  @override
  String getEntriesPath() => '/api/users/$id/entries';
  @override
  String getPostsPath() => '/api/users/$id/posts';
}

class FeedSourceDomain implements FeedSource {
  final int id;

  const FeedSourceDomain(this.id);

  @override
  String getEntriesPath() => '/api/domain/$id/entries';
  @override
  String? getPostsPath() => null;
}
