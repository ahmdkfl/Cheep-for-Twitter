import 'package:flutter/material.dart';
import 'package:cheep_for_twitter/tweet.dart';

class TweetCard extends Card {

  String profileImage;
  String userName;
  String name;
  String text;
  int retweetCount;
  int favoriteCount;
  int repliesCount;
  bool retweeted;

  TweetCard(String userName, String name, String profileImage, String text, int retweetCount, int favoriteCount, int repliesCount){
    this.userName = userName;
    this.name = name;
    this.profileImage = profileImage;
    this.text = text;
    this.retweetCount = retweetCount;
    this.favoriteCount = favoriteCount;
    this.repliesCount = repliesCount;
    this.retweeted = false;
  }

  static TweetCard fromTweet(Tweet tweet){
    // var userName, name, profileImage, text, retweetCount, favoriteCount, repliesCount;
    var u, n, p, t, r, f, r2, retweeted = false;
    // print(tweet.text);
      if(tweet.retweetedStatus == null && !tweet.truncated){
        u = tweet.user['screen_name'];
        n = tweet.user['name'];
        p = tweet.user['profile_image_url_https'].replaceAll(new RegExp(r'normal'), '200x200');
        t = tweet.text;
        r = tweet.retweetCount;
        f = tweet.favoriteCount;
        r2 = 0;
      } else if (tweet.retweetedStatus == null && tweet.truncated){
        u = tweet.user['screen_name'];
        n = tweet.user['name'];
        p = tweet.user['profile_image_url_https'].replaceAll(new RegExp(r'normal'), '200x200');
        t = tweet.text;
        r = tweet.retweetCount;
        f = tweet.favoriteCount;
        r2 = 0;
      }
      else if(tweet.retweetedStatus != null && !tweet.truncated){
        u = tweet.retweetedStatus['user']['screen_name'];
        n = tweet.retweetedStatus['user']['name'];
        p = tweet.retweetedStatus['user']['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200');
        t = tweet.retweetedStatus['text'];
        r = tweet.retweetedStatus['retweet_count'];
        f = tweet.retweetedStatus['favorite_count'];
        r2 = 0;
        retweeted = true;
      }
      else if(tweet.retweetedStatus != null && tweet.truncated){
        u = tweet.retweetedStatus['user']['screen_name'];
        n = tweet.retweetedStatus['user']['name'];
        p = tweet.retweetedStatus['user']['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200');
        t = tweet.retweetedStatus['extended_tweet']['full_text'];
        r = tweet.retweetedStatus['retweet_count'];
        f = tweet.retweetedStatus['favorite_count'];
        r2 = 0;
        retweeted = true;
      }
    return TweetCard(u, n, p, t, r, f, r2);
  }

  @override
  Widget build(BuildContext context) {

    return new Card(child: 
      Padding(padding: EdgeInsets.all(9),
        child:Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0), child:
              ClipOval(
                child: Image.network(
                  profileImage.replaceAll(new RegExp(r'normal'), '200x200'),
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(child: 
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(" @"+userName, style: TextStyle(color: Colors.grey),)
                  ]),
                  Text(text),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                    Row(children: <Widget>[
                      Icon(Icons.replay, size: 15),
                      Text(retweetCount.toString())
                      ]
                    ),
                    Row(children: <Widget>[
                      Icon(Icons.favorite, size: 15),
                      Text(favoriteCount.toString()),
                      ]
                    ),
                    Row(children: <Widget>[
                      Icon(Icons.reply, size: 15),
                      Text(repliesCount.toString())
                      ]
                    ),
                  ],)
                ]
              )
            )
            ]
          )
        )
      );
  }
}