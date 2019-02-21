import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet.dart';
import 'package:cheep_for_twitter/tweet_card.dart';

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