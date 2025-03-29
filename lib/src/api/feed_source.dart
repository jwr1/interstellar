enum FeedSource {
  all,
  local,
  subscribed,
  moderated,
  favorited,
  magazine,
  user,
  domain,
}

enum FeedSort {
  active,
  hot,
  newest,
  oldest,
  top,
  commented,

  //lemmy specific
  topDay,
  topWeek,
  topMonth,
  topYear,
  newComments,
  topHour,
  topSixHour,
  topTwelveHour,
  topThreeMonths,
  topSixMonths,
  topNineMonths,
  controversial,
  scaled,
}
