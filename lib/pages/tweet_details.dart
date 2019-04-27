import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'dart:convert';

class TweetDetails extends StatelessWidget {
  final Tweet tweet;

  TweetDetails({Key key, @required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: Text("Tweet")),
        body: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: _loadReplies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var tweets = snapshot.data['statuses'];

                  List<Widget> list = new List<Widget>();
                  list.add(TweetCard(tweet: tweet, type: TweetCard.detail));
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
                    Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator());
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
                } else if(snapshot.hasError)
                  return Column(
                    children: <Widget>[
                      Text("Limit reached!"),
                    ],
                  );
                  else
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

  Future<Map<String, dynamic>> _loadReplies() async {
    var client = Twitterapi().getClient();
    var result = await client.get(
        'https://api.twitter.com/1.1/search/tweets.json?count=100&q=' +
            tweet.user['screen_name'].toString() +
            "&since_id=" +
            tweet.idStr.toString());
    Map<String, dynamic> data = json.decode(result.body);
    return data;
  }
}
