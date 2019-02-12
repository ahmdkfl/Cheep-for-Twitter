class Tweet {
  final int userID;
  final String name;
  final String username;
  final String text;
  final Map<String, dynamic> retweet_status;
  var user;

  Tweet({this.userID, this.name, this.username, this.text, this.retweet_status, this.user});

  factory Tweet.fromJson(Map<String, dynamic> usersjson) => Tweet(
      userID: usersjson["id"],
      name: usersjson["name"],
      username: usersjson["username"],
      text: usersjson['text'],
      retweet_status: usersjson['retweeted_status'],
      user: usersjson['user']
  );
}