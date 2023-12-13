abstract class ContentSource {
  String getPath();
}

class ContentAll implements ContentSource {
  const ContentAll();

  @override
  String getPath() => '/api/entries';
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
