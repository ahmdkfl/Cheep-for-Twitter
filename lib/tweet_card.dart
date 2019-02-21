import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheep_for_twitter/tweet.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';


class TweetCard extends Card {

  String profileImage;
  String userName;
  String name;
  String text;
  int retweetCount;
  int favoriteCount;
  int repliesCount;
  bool retweeted;
  List<String> images;

  TweetCard(String userName, String name, String profileImage, String text, int retweetCount, int favoriteCount, int repliesCount, List<String> images){
    this.userName = userName;
    this.name = name;
    this.profileImage = profileImage;
    this.text = text;
    this.retweetCount = retweetCount;
    this.favoriteCount = favoriteCount;
    this.repliesCount = repliesCount;
    this.retweeted = false;
    this.images = images;
  }

  static TweetCard fromTweet(Tweet tweet){
    // var userName, name, profileImage, text, retweetCount, favoriteCount, repliesCount;
    var u, n, p, t, r, f, r2, retweeted = false;
    List<String> i = new List<String>();
    if(tweet.extendedEntities != null){
      List<dynamic> result = tweet.extendedEntities['media'];
      result.forEach((res){
        print(res['media_url_https']);
        i.add(res['media_url_https']);
      });
    }
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
    return TweetCard(u, n, p, t, r, f, r2, i);
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

class LinkPage extends StatelessWidget {

  final String address;

  LinkPage({Key key, @required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var authorizePage = new WebviewScaffold(
      url: address,
      appBar: new AppBar(
        title: new Text("Cheep Login"),
      ),
    );

    return authorizePage;
  }
}

class ImageZoom extends StatelessWidget {

  final String url;

  ImageZoom({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: url,
            child: CachedNetworkImage(
              placeholder: CircularProgressIndicator(),
              imageUrl:url
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
