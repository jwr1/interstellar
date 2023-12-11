String extractMag(String user) => user.split('@').first;

String extractUser(String user) =>
    (user.startsWith('@') ? user.substring(1) : user).split('@').first;

String timeDiffFormat(DateTime input) {
  final difference = DateTime.now().difference(input);

  if (difference.inDays > 0) {
    var years = (difference.inDays / 365).truncate();
    if (years >= 1) {
      return "${years}Y";
    }

    var months = (difference.inDays / 30).truncate();
    if (months >= 1) {
      return "${months}M";
    }

    var weeks = (difference.inDays / 7).truncate();
    if (weeks >= 1) {
      return "${weeks}w";
    }

    var days = difference.inDays;
    return "${days}d";
  }

  var hours = difference.inHours;
  if (hours > 0) {
    return "${hours}h";
  }

  var minutes = difference.inMinutes;
  if (minutes > 0) {
    return "${minutes}m";
  }

  var seconds = difference.inSeconds;
  return "${seconds}s";
}
