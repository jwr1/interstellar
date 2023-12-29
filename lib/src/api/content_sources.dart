abstract class ContentSource {
  String getPath();
}

// entries sources
class ContentAll implements ContentSource {
  const ContentAll();

  @override
  String getPath() => '/api/entries';
}

class ContentSub implements ContentSource {
  const ContentSub();

  @override
  String getPath() => '/api/entries/subscribed';
}

class ContentMod implements ContentSource {
  const ContentMod();

  @override
  String getPath() => '/api/entries/moderated';
}

class ContentFav implements ContentSource {
  const ContentFav();

  @override
  String getPath() => '/api/entries/favourited';
}

class ContentMagazine implements ContentSource {
  final int id;

  const ContentMagazine(this.id);

  @override
  String getPath() => '/api/magazine/$id/entries';
}

class ContentUser implements ContentSource {
  final int id;

  const ContentUser(this.id);

  @override
  String getPath() => '/api/users/$id/entries';
}

class ContentDomain implements ContentSource {
  final int id;

  const ContentDomain(this.id);

  @override
  String getPath() => '/api/domain/$id/entries';
}

// posts sources
class ContentPostsAll implements ContentSource {
  const ContentPostsAll();

  @override
  String getPath() => '/api/posts';
}

class ContentPostsSub implements ContentSource {
  const ContentPostsSub();

  @override
  String getPath() => '/api/posts/subscribed';
}

class ContentPostsMod implements ContentSource {
  const ContentPostsMod();

  @override
  String getPath() => '/api/posts/moderated';
}

class ContentPostsFav implements ContentSource {
  const ContentPostsFav();

  @override
  String getPath() => '/api/posts/favourited';
}

class ContentPostsMagazine implements ContentSource {
  final int id;

  const ContentPostsMagazine(this.id);

  @override
  String getPath() => '/api/magazine/$id/posts';
}

class ContentPostsUser implements ContentSource {
  final int id;

  const ContentPostsUser(this.id);

  @override
  String getPath() => '/api/users/$id/posts';
}

class ContentPostsDomain implements ContentSource {
  final int id;

  const ContentPostsDomain(this.id);

  @override
  String getPath() => '/api/domain/$id/posts';
}