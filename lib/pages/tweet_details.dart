import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';

class TweetDetails extends StatelessWidget {

  final Tweet tweet;

  TweetDetails({Key key, @required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
      body: TweetCard.fromTweet(tweet)
    );
  }
}