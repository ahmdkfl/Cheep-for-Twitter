class Tweet {
  final String createAt;
  final String idStr;
  final String text;
  final bool truncated;
  final int retweetCount;
  final int favoriteCount;
  final bool retweeted;
  final bool favorited;
  final Map<String, dynamic> user;
  final Map<String, dynamic> place;
  final Map<String, dynamic> entities;
  final Map<String, dynamic> extendedEntities;
  final Map<String, dynamic> extendedTweet;
  final Map<String, dynamic> quotedStatus;
  final Map<String, dynamic> retweetedStatus;

  Tweet({this.createAt, this.idStr, this.text, this.truncated, this.retweetCount, this.favoriteCount, this.retweeted, this.favorited, this.user, this.place, this.entities, this.extendedEntities, this.extendedTweet, this.quotedStatus, this.retweetedStatus});

  factory Tweet.fromJson(Map<String, dynamic> usersjson) => Tweet(
      createAt: usersjson["create_at"] ?? null,
      idStr: usersjson["id_str"] ?? null,
      text: usersjson["text"] ?? null,
      truncated: usersjson['truncated'] ?? null,
      retweetCount: usersjson['retweet_count'] ?? null,
      favoriteCount: usersjson['favorite_count'] ?? null,
      retweeted: usersjson['retweeted'] ?? null,
      favorited: usersjson['favorited'] ?? null,
      user: usersjson['user'] ?? null,
      place: usersjson['place'] ?? null,
      entities: usersjson['entities'] ?? null,
      extendedEntities: usersjson['extended_entities'] ?? null,
      extendedTweet: usersjson['extended_tweet'] ?? null,
      quotedStatus: usersjson['quoted_status'] ?? null,
      retweetedStatus: usersjson['retweeted_status'] ?? null
  );

  bool isEmpty(){
    return idStr == "";
  }
}