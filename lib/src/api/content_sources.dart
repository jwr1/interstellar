enum ContentSort { active, hot, newest, oldest, top, commented }

abstract class ContentSource {
  String getEntriesPath();
  String? getPostsPath();
}

class ContentAll implements ContentSource {
  const ContentAll();

  @override
  String getEntriesPath() => '/api/entries';
  @override
  String getPostsPath() => '/api/posts';
}

class ContentSub implements ContentSource {
  const ContentSub();

  @override
  String getEntriesPath() => '/api/entries/subscribed';
  @override
  String getPostsPath() => '/api/posts/subscribed';
}

class ContentMod implements ContentSource {
  const ContentMod();

  @override
  String getEntriesPath() => '/api/entries/moderated';
  @override
  String getPostsPath() => '/api/posts/moderated';
}

class ContentFav implements ContentSource {
  const ContentFav();

  @override
  String getEntriesPath() => '/api/entries/favourited';
  @override
  String getPostsPath() => '/api/posts/favourited';
}

class ContentMagazine implements ContentSource {
  final int id;

  const ContentMagazine(this.id);

  @override
  String getEntriesPath() => '/api/magazine/$id/entries';
  @override
  String getPostsPath() => '/api/magazine/$id/posts';
}

class ContentUser implements ContentSource {
  final int id;

  const ContentUser(this.id);

  @override
  String getEntriesPath() => '/api/users/$id/entries';
  @override
  String getPostsPath() => '/api/users/$id/posts';
}

class ContentDomain implements ContentSource {
  final int id;

  const ContentDomain(this.id);

  @override
  String getEntriesPath() => '/api/domain/$id/entries';
  @override
  String? getPostsPath() => null;
}
