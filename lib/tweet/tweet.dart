
/// A class that contains all the elements that make up a tweet
class Tweet {
  final String createdAt;
  final String idStr;
  final String text;
  final String source;
  final bool truncated;
  final int retweetCount;
  final int favoriteCount;
  final bool retweeted;
  final bool favorited;
  final String inReplyStatusId;
  final Map<String, dynamic> user;
  final Map<String, dynamic> place;
  final Map<String, dynamic> entities;
  final Map<String, dynamic> extendedEntities;
  final Map<String, dynamic> extendedTweet;
  final Map<String, dynamic> quotedStatus;
  final Map<String, dynamic> retweetedStatus;

  /// Constructor that takes in the different variables that are required declared
  Tweet({this.createdAt, this.idStr, this.text, this.source, this.truncated, this.retweetCount, this.favoriteCount, this.retweeted, this.favorited, this.inReplyStatusId,this.user, this.place, this.entities, this.extendedEntities, this.extendedTweet, this.quotedStatus, this.retweetedStatus});

  /// Map the JSON string into a Tweet class
  factory Tweet.fromJson(Map<String, dynamic> usersjson) => Tweet(
      createdAt: usersjson["created_at"] ?? null,
      idStr: usersjson["id_str"] ?? null,
      text: usersjson["text"] ?? null,
      truncated: usersjson['truncated'],
      retweetCount: usersjson['retweet_count'] ?? null,
      favoriteCount: usersjson['favorite_count'] ?? null,
      retweeted: usersjson['retweeted'] ?? null,
      favorited: usersjson['favorited'] ?? null,
      inReplyStatusId: usersjson['in_reply_to_status_id_str'] ?? null,
      user: usersjson['user'] ?? null,
      place: usersjson['place'] ?? null,
      entities: usersjson['entities'] ?? null,
      extendedEntities: usersjson['extended_entities'] ?? null,
      extendedTweet: usersjson['extended_tweet'] ?? null,
      quotedStatus: usersjson['quoted_status'] ?? null,
      retweetedStatus: usersjson['retweeted_status'] ?? null
  );
}