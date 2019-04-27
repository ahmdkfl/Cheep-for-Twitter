import 'dart:convert';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:cheep_for_twitter/pages/tweet_details.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

class HomeTimeline extends StatefulWidget {
  HomeTimeline({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeTimelineState();
}

class HomeTimelineState extends State<HomeTimeline>
    with AutomaticKeepAliveClientMixin {
  Future<dynamic> _loadHomeTimeline;
  static List<Widget> _cachedTweets;

  @override
  void initState() {
    super.initState();
    _loadHomeTimeline = _getHomeTimelineInfo();
    _cachedTweets = List<Widget>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _loadHomeTimeline,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<dynamic> userTweets = json.decode(snapshot.data.body);

            List<Widget> list = new List<Widget>();
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
              _cachedTweets = list;
            } else
              Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
            return StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: _cachedTweets.length,
                    itemBuilder: (context, index) {
                      return _cachedTweets[index];
                    },
                  );
                });
          } else
            return Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<dynamic> _getHomeTimelineInfo() async {
    var client = Twitterapi().getClient();
    return await client.get(
        'https://api.twitter.com/1.1/statuses/home_timeline.json?count=200&tweet_mode=extended');
  }
}
