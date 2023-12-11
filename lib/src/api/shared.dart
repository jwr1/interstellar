class User {
  late int userId;
  late String username;
  late bool isBot;
  bool? isFollowedByUser;
  bool? isFollowerOfUser;
  bool? isBlockedByUser;
  Image? avatar;
  String? apId;
  String? apProfileId;
  late DateTime createdAt;

  User(
      {required this.userId,
      required this.username,
      required this.isBot,
      this.isFollowedByUser,
      this.isFollowerOfUser,
      this.isBlockedByUser,
      this.avatar,
      this.apId,
      this.apProfileId,
      required this.createdAt});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    username = json['username'];
    isBot = json['isBot'];
    isFollowedByUser = json['isFollowedByUser'];
    isFollowerOfUser = json['isFollowerOfUser'];
    isBlockedByUser = json['isBlockedByUser'];
    avatar = json['avatar'] != null ? Image.fromJson(json['avatar']) : null;
    apId = json['apId'];
    apProfileId = json['apProfileId'];
    createdAt = DateTime.parse(json['createdAt']);
  }
}

class Magazine {
  late String name;
  late int magazineId;
  Image? icon;
  bool? isUserSubscribed;
  bool? isBlockedByUser;
  String? apId;
  late String apProfileId;

  Magazine(
      {required this.name,
      required this.magazineId,
      this.icon,
      this.isUserSubscribed,
      this.isBlockedByUser,
      this.apId,
      required this.apProfileId});

  Magazine.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    magazineId = json['magazineId'];
    icon = json['icon'] != null ? Image.fromJson(json['icon']) : null;
    isUserSubscribed = json['isUserSubscribed'];
    isBlockedByUser = json['isBlockedByUser'];
    apId = json['apId'];
    apProfileId = json['apProfileId'];
  }
}

class Image {
  late String filePath;
  String? sourceUrl;
  late String storageUrl;
  String? altText;
  late int width;
  late int height;

  Image(
      {required this.filePath,
      this.sourceUrl,
      required this.storageUrl,
      this.altText,
      required this.width,
      required this.height});

  Image.fromJson(Map<String, dynamic> json) {
    filePath = json['filePath'];
    sourceUrl = json['sourceUrl'];
    storageUrl = json['storageUrl'];
    altText = json['altText'];
    width = json['width'];
    height = json['height'];
  }
}

class Pagination {
  late int count;
  late int currentPage;
  late int maxPage;
  late int perPage;

  Pagination(
      {required this.count,
      required this.currentPage,
      required this.maxPage,
      required this.perPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    currentPage = json['currentPage'];
    maxPage = json['maxPage'];
    perPage = json['perPage'];
  }
}
