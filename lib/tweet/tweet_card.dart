import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';
import 'package:cheep_for_twitter/tweet/retweet_widget.dart';
import 'package:cheep_for_twitter/pages/link_page.dart';
import 'package:cheep_for_twitter/pages/image_zoom.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';


class TweetCard extends Card {

  String profileImage;
  String userName;
  String name;
  String text;
  int retweetCount;
  int favoriteCount;
  int repliesCount;
  bool favorited;
  bool retweeted;
  List<String> images;

  TweetCard(String userName, String name, String profileImage, String text, int retweetCount, int favoriteCount, int repliesCount, bool favorited, bool retweeted, List<String> images){
    this.userName = userName;
    this.name = name;
    this.profileImage = profileImage;
    this.text = text;
    this.retweetCount = retweetCount;
    this.favoriteCount = favoriteCount;
    this.repliesCount = repliesCount;
    this.favorited = favorited;
    this.retweeted = retweeted;
    this.images = images;
  }

  static TweetCard fromTweet(Tweet tweet){
    // var userName, name, profileImage, text, retweetCount, favoriteCount, repliesCount;
    String userName, name, profileImage, text;
    int retweetCount, favoriteCount, repliesCount;
    bool favorited, retweeted;
    List<String> images = new List<String>();
    if(tweet.extendedEntities != null){
      List<dynamic> result = tweet.extendedEntities['media'];
      result.forEach((res){
        images.add(res['media_url_https']);
      });
    }
      if(tweet.retweetedStatus == null && !tweet.truncated){
        userName = tweet.user['screen_name'];
        name = tweet.user['name'];
        profileImage = tweet.user['profile_image_url_https'].replaceAll(new RegExp(r'normal'), '200x200');
        text = tweet.text;
        retweetCount = tweet.retweetCount;
        favoriteCount = tweet.favoriteCount;
        favorited = tweet.favorited;
        retweeted = tweet.retweeted;
        repliesCount = 0;
      } else if (tweet.retweetedStatus == null && tweet.truncated){
        userName = tweet.user['screen_name'];
        name = tweet.user['name'];
        profileImage = tweet.user['profile_image_url_https'].replaceAll(new RegExp(r'normal'), '200x200');
        text = tweet.text;
        retweetCount = tweet.retweetCount;
        favoriteCount = tweet.favoriteCount;
        favorited = tweet.favorited;
        retweeted = tweet.retweeted;
        repliesCount = 0;
      }
      else if(tweet.retweetedStatus != null && !tweet.truncated){
        userName = tweet.retweetedStatus['user']['screen_name'];
        name = tweet.retweetedStatus['user']['name'];
        profileImage = tweet.retweetedStatus['user']['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200');
        text = tweet.retweetedStatus['text'];
        retweetCount = tweet.retweetedStatus['retweet_count'];
        favoriteCount = tweet.retweetedStatus['favorite_count'];
        favorited = tweet.favorited;
        retweeted = tweet.retweeted;
        repliesCount = 0;
      }
      else if(tweet.retweetedStatus != null && tweet.truncated){
        userName = tweet.retweetedStatus['user']['screen_name'];
        name = tweet.retweetedStatus['user']['name'];
        profileImage = tweet.retweetedStatus['user']['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200');
        text = tweet.retweetedStatus['extended_tweet']['full_text'];
        retweetCount = tweet.retweetedStatus['retweet_count'];
        favoriteCount = tweet.retweetedStatus['favorite_count'];
        favorited = tweet.favorited;
        retweeted = tweet.retweeted;
        repliesCount = 0;
      }
    return TweetCard(userName, name, profileImage, text, retweetCount, favoriteCount, repliesCount, favorited, retweeted, images);
  }

  @override
  Widget build(BuildContext context) {
    return new Card(child:  Padding(padding: EdgeInsets.all(9),
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
                    Linkify(
                      onOpen: (url) async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LinkPage(address: url),
                        ));
                      },
                      text: text,
                      style: TextStyle(color: Colors.black),
                      linkStyle: TextStyle(color: Colors.red),
                      humanize: true,
                    ),
                    Column(
                      children: _getTweetImages(context)
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                      RetweetWidget(isRetweeted: retweeted, retweetCount:retweetCount),
                      FavoriteWidget(isFavorited: favorited, favoriteCount: favoriteCount),
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
          ),
      );
  }

  List<Widget> _getTweetImages(context){
    List<Widget> list = new List();
    images.forEach((image){

      list.add(
        GestureDetector(
          child: Hero(
            tag: image,
            child: Image.network(image)
          ),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_){
              return ImageZoom(url: image);
            }));
          },
        )
      );
    });
    return list;
  }
  
}


