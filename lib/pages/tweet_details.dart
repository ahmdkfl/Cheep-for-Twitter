import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'dart:convert';

/// Shows details of a tweet
class TweetDetails extends StatelessWidget {
  // Tweet that the details has to shown
  Tweet tweet;

  TweetDetails({Key key, @required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If it is a retweet then get the original tweet from retweeted_status
    if (tweet.retweetedStatus != null)
      tweet = Tweet.fromJson(tweet.retweetedStatus);
    return Scaffold(
        // Title of the screen
        appBar: new AppBar(title: Text("Tweet")),
        body: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              // Future data contains the replies to the tweets
              future: _loadReplies(),
              builder: (context, snapshot) {
                // If the computation of the future is finished
                if (snapshot.connectionState == ConnectionState.done) {
                  var tweets = snapshot.data['statuses'];

                  List<Widget> list = new List<Widget>();
                  // Add the tweet card to the list as a detailed card
                  list.add(TweetCard(tweet: tweet, type: TweetCard.detail));
                  // Fetch replies to the tweet
                  if (tweets != null)
                    tweets.forEach((tweetItem) {
                      var t = Tweet.fromJson(tweetItem);
                      if (tweetItem['in_reply_to_status_id_str'] == tweet.idStr)
                        list.add(GestureDetector(
                          child: TweetCard(tweet: t),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return TweetDetails(tweet: t);
                            }));
                          },
                        ));
                    });
                  else
                    // Otherwise show a loading sign
                    Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator());
                  // Display the tweets
                  return StreamBuilder<Object>(
                      stream: null,
                      builder: (context, snapshot) {
                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return list[index];
                          },
                        );
                      });
                } else
                  return Column(children: <Widget>[
                    Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator())
                  ]);
              },
            ))
          ],
        ));
  }

  /// Retrieves the replies a tweet
  Future<Map<String, dynamic>> _loadReplies() async {
    // Retrieve the static instance of the client (Singleton)
    var client = Twitterapi().getClient();
    var result = await client.get(
        'https://api.twitter.com/1.1/search/tweets.json?tweet_mode=extended&count=100&q=' +
            tweet.user['screen_name'].toString() +
            "&since_id=" +
            tweet.idStr.toString());
    // Decode the result as a map
    Map<String, dynamic> data = json.decode(result.body);
    return data;
  }
}
