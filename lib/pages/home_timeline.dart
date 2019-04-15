import 'dart:convert';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card4.dart';
import 'package:cheep_for_twitter/pages/tweet_details.dart';

class HomeTimeline extends StatefulWidget {
  var client;

  HomeTimeline({Key key, @required this.client}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeTimelineState();
}

class HomeTimelineState extends State<HomeTimeline>
    with AutomaticKeepAliveClientMixin {
  Future<dynamic> _loadHomeTimeline;
  List<Widget> _cachedTweets;

  @override
  void initState() {
    _loadHomeTimeline = _getHomeTimelineInfo(widget.client);
    _cachedTweets = List<Widget>();
    super.initState();
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
            if(_cachedTweets.isEmpty){
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
              }
            return ListView.builder(
              itemCount: _cachedTweets.length,
              itemBuilder: (context, index) {
                return _cachedTweets[index];
              },
            );
          } else
            return Center(child:CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<dynamic> _getHomeTimelineInfo(client) async {
    return await client.get(
        'https://api.twitter.com/1.1/statuses/home_timeline.json?count=200');
  }
}
