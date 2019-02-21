import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tweet.dart';
import 'package:cheep_for_twitter/tweet_card.dart';
import 'package:cheep_for_twitter/tweet_details.dart';

class HomeTimeline extends StatefulWidget {

  var _client;

  HomeTimeline(client){
    _client = client;
  }

  @override
  State<StatefulWidget> createState() => HomeTimelineState(_client);
  
}

class HomeTimelineState extends State<HomeTimeline> with AutomaticKeepAliveClientMixin {

  var _client;

  HomeTimelineState(c){
    _client = c;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getHomeTimelineInfo(_client),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            List<dynamic> userTweets = json.decode(snapshot.data.body);

            List<Widget> list = new List<Widget>();
            userTweets.forEach((tweet){
              var t = Tweet.fromJson(tweet);
              list.add(
                GestureDetector(
                  child: TweetCard.fromTweet(t),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_){
                      return TweetDetails(tweet: tweet);
                    }));
                  },
                )
              );
            });
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return list[index];
              },
            );
            }
          else
            return Column(children: <Widget>[CircularProgressIndicator()]);
        },
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;

  Future<dynamic> _getHomeTimelineInfo(client){
    return client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=200').then((res) {
        return res;
    });
  }
  
}