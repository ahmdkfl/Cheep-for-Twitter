import 'package:flutter/material.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';
import 'package:cheep_for_twitter/tweet/retweet_widget.dart';
import 'package:cheep_for_twitter/tweet/reply_widget.dart';
import 'package:cheep_for_twitter/pages/profile.dart';
import 'package:cheep_for_twitter/pages/image_zoom.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TweetCard extends StatefulWidget {
  Tweet tweet;

  TweetCard({Key key, @required this.tweet})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TweetCardState();
}

class TweetCardState extends State<TweetCard> {
  String createdAt;
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
  bool hasRetweeted;

  void initState() {
    images = List<String>();
    getData(widget.tweet);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          isRetweeted(hasRetweeted, widget.tweet.user['name']),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: GestureDetector(
                      child: ClipOval(
                        child: CachedNetworkImage(
                            imageUrl: image,
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                            height: 55,
                            width: 55,
                            fit: BoxFit.cover),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          var user;
                          if (hasRetweeted)
                            user = widget.tweet.retweetedStatus['user'];
                          else
                            user = widget.tweet.user;

                          return Profile(user: user);
                        }));
                      },
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(" @" + userName,
                              style: TextStyle(color: Colors.grey),
                              overflow: TextOverflow.fade),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 3.0),
                        child: Text(
                          text,
                          softWrap: true,
                        ),
                      ),
                      Column(children: _getTweetImages()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ReplyWidget(isReplied: false),
                          RetweetWidget(
                              isRetweeted: retweeted,
                              retweetCount: retweetCount),
                          FavoriteWidget(
                              isFavorited: favorited,
                              favoriteCount: favoriteCount),
                        ],
                      )
                    ],
                  ))
                ]),
          ),
          Divider(height: 5)
        ],
      ),
    );
  }

  Widget isRetweeted(ret, name) {
    if (ret)
      return Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Text(name + " Retweeted",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
    return Container();
  }

  List<Widget> _getTweetImages() {
    List<Widget> list = new List();
    if (mediaType == "photo")
      images.forEach((image) {
        list.add(GestureDetector(
          child: Container(
            child: ClipRRect(
              child: CachedNetworkImage(
                imageUrl: image,
                placeholder: (context, url) => Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              border: new Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ImageZoom(url: image);
            }));
          },
        ));
      });
    else if (mediaType == "video") {
      final videoPlayerController = VideoPlayerController.network(images[0]);

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

  getData(Tweet tweet) {
    if (tweet.extendedEntities != null) {
      List<dynamic> result;
      if(tweet.retweetedStatus == null)
        result = tweet.extendedEntities['media'];
      else
        result = tweet.retweetedStatus['extended_entities']['media'];
      result.forEach((res) {
        mediaType = res['type'];
        if (mediaType == "video") {
          images.add(res['video_info']['variants'][0]['url']);
        } else if (mediaType == "animated_gif")
          images.add(res['video_info']['variants'][0]['url']);
        else
          images.add(res['media_url_https']);
      });
    }

    favorited = tweet.favorited;
    retweeted = tweet.retweeted;
    createdAt = tweet.createdAt;
    hasRetweeted = false;
    if (tweet.retweetedStatus == null) {
      userName = tweet.user['screen_name'];
      name = tweet.user['name'];
      image = tweet.user['profile_image_url_https']
          .replaceAll(new RegExp(r'normal'), '200x200');
      retweetCount = tweet.retweetCount;
      favoriteCount = tweet.favoriteCount;
      if (tweet.truncated)
        text = tweet.text;
      else
        text = tweet.text;
    } else {
      userName = tweet.retweetedStatus['user']['screen_name'];
      name = tweet.retweetedStatus['user']['name'];
      image = tweet.retweetedStatus['user']['profile_image_url']
          .replaceAll(new RegExp(r'normal'), '200x200');
      if (!tweet.truncated)
        text = tweet.retweetedStatus['text'];
      else
        text = tweet.retweetedStatus['extended_tweet']['text'];
      hasRetweeted = true;
      retweetCount = tweet.retweetedStatus['retweet_count'];
      favoriteCount = tweet.retweetedStatus['favorite_count'];
      createdAt = tweet.retweetedStatus['created_at'];
    }
  }
}
