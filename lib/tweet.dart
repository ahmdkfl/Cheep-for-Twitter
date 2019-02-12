class Tweet {
  final int userID;
  final String name;
  final String username;

  Tweet({this.userID, this.name, this.username});

  factory Tweet.fromJson(Map<String, dynamic> usersjson)=> Tweet(
      userID: usersjson["id"],
      name: usersjson["name"],
      username: usersjson["username"],
  );
}