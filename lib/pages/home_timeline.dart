import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:cheep_for_twitter/pages/tweet_details.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

/// Hometimeline of the authenticating user
/// Displays tweets and retweets from the user timeline
class HomeTimeline extends StatefulWidget {
  HomeTimeline({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeTimelineState();
}

class HomeTimelineState extends State<HomeTimeline>
    with AutomaticKeepAliveClientMixin {
  // Computation executed in the future
  Future<dynamic> _loadHomeTimeline;
  // The already loaded tweet are save in this static variable
  static List<Widget> _cachedTweets;

  @override
  void initState() {
    super.initState();
    // Set up the future
    _loadHomeTimeline = _getHomeTimelineInfo();
    // Saved tweets
    _cachedTweets = List<Widget>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget that executes the future _loadHomeTimeline
      child: FutureBuilder(
        future: _loadHomeTimeline,
        // The snapshot contains all the computed that from the future
        builder: (context, snapshot) {
          // If the computation is finished and the data not contains the code error 88
          // (Standard Twitter APIs limits the call to 15 every 15 minutes), then
          // load the data in a list
          if (snapshot.connectionState == ConnectionState.done &&
              !(snapshot.data.body).toString().contains("\"code\":88")) {
            List<dynamic> userTweets = json.decode(snapshot.data.body);

            List<Widget> list = new List<Widget>();
            // if the user tweets are not null and _cachedTweets are not empty
            // then parse the JSON file that contains the tweet in a variable
            // called t and then add it to the list
            if (userTweets != null && _cachedTweets.isEmpty) {
              userTweets.forEach((tweet) {
                var t = Tweet.fromJson(tweet);
                list.add(GestureDetector(
                  child: TweetCard(tweet: t),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return TweetDetails(tweet: t);
                    }));
                  },
                ));
              });
              // the list is given to the _cachedTweets
              _cachedTweets = list;
            }
            // if the _cachedTweet are not empty when the screen is reloaded
            // then display a loading widget
          } else if (_cachedTweets.isEmpty)
            // Loading widget aligned at the center
            return Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          // return the display using a StreamBuilder
          return StreamBuilder<Object>(
              stream: null,
              builder: (context, snapshot) {
                // ListView is used to easily build a list of custom item given a list
                return ListView.builder(
                  itemCount: _cachedTweets.length,
                  itemBuilder: (context, index) {
                    return _cachedTweets[index];
                  },
                );
              });
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // Retrieves the maximum of 200 from the timeline of the user
  Future<dynamic> _getHomeTimelineInfo() async {
    // Retrieve the static instance of the client (Singleton)
    var client = Twitterapi().getClient();
    return await client.get(
        'https://api.twitter.com/1.1/statuses/home_timeline.json?count=200&tweet_mode=extended');
  }
}
