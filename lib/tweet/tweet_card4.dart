
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';
import 'package:cheep_for_twitter/tweet/retweet_widget.dart';
import 'package:cheep_for_twitter/tweet/reply_widget.dart';
import 'package:cheep_for_twitter/pages/link_page.dart';
import 'package:cheep_for_twitter/pages/image_zoom.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';


class TweetCard extends StatefulWidget {

  Tweet tweet;

  TweetCard({Key key, this.tweet}):super(key: key);

  @override
  State<StatefulWidget> createState() => TweetCardState();
  
}

class TweetCardState extends State<TweetCard> {

  String image;
  String name;
  String userName;
  String text;
  String mediaType;
  List<String> images;
  bool favorited;
  int favoriteCount;
  bool retweeted;
  int retweetCount;

  void initState() {
    images = List<String>();
    getData(widget.tweet);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final tweetCard = new Container(
      margin: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3.0,
            offset: Offset(0.0, 2.0)
          )
        ]
      ),
    );

    return new Container(
      child: Stack(
        children: <Widget>[
          tweetCard,
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                isRetweeted(retweeted),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(child: 
                      ClipOval(
                        child: Image.network(
                          image,
                          height: 55,
                          width: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),                      
                        child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                                Text(" @"+userName, style: TextStyle(color: Colors.grey), overflow: TextOverflow.fade),
                              ],),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 3.0),
                                child: 
                                  Text(text,softWrap: true,),
                              ),
                              Column(
                                children: _getTweetImages()
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ReplyWidget(isReplied: false, replyCount: 2),
                                  RetweetWidget(isRetweeted: retweeted, retweetCount: retweetCount),
                                  FavoriteWidget(isFavorited: favorited, favoriteCount: favoriteCount),
                                  FavoriteWidget(isFavorited: true, favoriteCount: 13),
                                ],
                              )
                            ],
                        ),
                      )
                    )
                  ]
                ),
                Divider(height: 20,)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget isRetweeted(ret){
    if(ret)
      return Container(margin: EdgeInsets.symmetric(vertical: 5),child: Text("You Retweeted", style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)));
    return Container();
  }

  List<Widget> _getTweetImages(){
    List<Widget> list = new List();
    if(mediaType == "photo")
      images.forEach((image){
        list.add(
          GestureDetector(
            child: Hero(
              tag: image,
              child: Container(
                  child: ClipRRect(child:Image.network(image,fit: BoxFit.contain),
                  borderRadius: BorderRadius.circular(10.0),),
                  width: double.infinity,
                  decoration: BoxDecoration(border:new Border.all(color: Colors.black12),borderRadius: BorderRadius.circular(10.0),),
                ),
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_){
                return ImageZoom(url: image);
              }));
            },
          )
        );
      });
    else if(mediaType == "video"){
      final videoPlayerController = VideoPlayerController.network(
        images[0]);

      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        looping: false,
      );

      final playerWidget = Chewie(
        controller: chewieController,
      );
      list.add(playerWidget);
    }
    return list;
  }

  Future<dynamic> _getReplies(client, id, sinceId){
    return client.get('https://api.twitter.com/1.1/search/tweets.json?count=20&q='+id.toString()+"&since_id="+sinceId.toString()).then((res) {
        return res;
    });
  }

  Future<String> _getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cred = prefs.getString("credentials");
    return cred;
  }

  getData(Tweet tweet){
    int repliesCount;
    if(tweet.extendedEntities != null){
      List<dynamic> result = tweet.extendedEntities['media'];
      result.forEach((res){
        mediaType = res['type'];
        if(mediaType=="video"){
          images.add(res['video_info']['variants'][0]['url']);
        } else if(mediaType=="animated_gif")
          images.add(res['video_info']['variants'][0]['url']);
        else
        images.add(res['media_url_https']);

      });
    }
    if(tweet.retweetedStatus == null && !tweet.truncated){
      userName = tweet.user['screen_name'];
      name = tweet.user['name'];
      image = tweet.user['profile_image_url_https'].replaceAll(new RegExp(r'normal'), '200x200');
      text = tweet.text;
      retweetCount = tweet.retweetCount;
      favoriteCount = tweet.favoriteCount;
      favorited = tweet.favorited;
      retweeted = tweet.retweeted;
      repliesCount = 0;
    } else if (tweet.retweetedStatus == null && tweet.truncated){
      userName = tweet.user['screen_name'];
      name = tweet.user['name'];
       image = tweet.user['profile_image_url_https'].replaceAll(new RegExp(r'normal'), '200x200');
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
      image = tweet.retweetedStatus['user']['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200');
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
      image = tweet.retweetedStatus['user']['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200');
      text = tweet.retweetedStatus['extended_tweet']['full_text'];
      retweetCount = tweet.retweetedStatus['retweet_count'];
      favoriteCount = tweet.retweetedStatus['favorite_count'];
      favorited = tweet.favorited;
      retweeted = tweet.retweeted;
      repliesCount = 0;
    }
    _getCredentials().then((credentials){
      var r = credentials;
      var r2 = r.split('=');
      var r3 = r2[1].split('&');
      var oauth_token_sec=r2[2];
      var oauth_token=r3[0];
      var client = Twitterapi().getAuthorClient(oauth_token, oauth_token_sec);
        _getReplies(client, userName, tweet.idStr).then((result){
          Map<String, dynamic> data = json.decode(result.body);
          var r = data['statuses'];
          r.forEach((t){
            // print(t['text']);
            // if(t['in_reply_to_status_id_str']==tweet.idStr)
            //   print(t['user']['screen_name']+";"+t['text']);
          });
        });
    });
  }
}

