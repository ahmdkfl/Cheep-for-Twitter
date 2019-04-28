import 'package:flutter/material.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';
import 'package:cheep_for_twitter/tweet/retweet_widget.dart';
import 'package:cheep_for_twitter/tweet/reply_widget.dart';
import 'package:cheep_for_twitter/pages/profile.dart';
import 'package:cheep_for_twitter/pages/image_zoom.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tweet card that display information about a tweet
class TweetCard extends StatefulWidget {
  // constants that define if the card is normal or detailed
  static const int normal = 0;
  static const int detail = 1;

  // Tweet to display
  Tweet tweet;
  // initilise the type of tweet as normal if no type parameter is passed in the constructor
  int type = TweetCard.normal;

  TweetCard({Key key, @required this.tweet, this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TweetCardState();
}

class TweetCardState extends State<TweetCard> {
  // Infomation about a tweet that can be displayed
  String createdAt;
  String image;
  String name;
  String userName;
  String text;
  String mediaType;
  List<String> images;
  List<String> urls;
  bool favorited;
  int favoriteCount;
  bool retweeted;
  int retweetCount;
  bool hasRetweeted;

  @override
  void initState() {
    super.initState();
    // initilise the images variable
    images = List<String>();
    // parse the information about the tweet
    getData(widget.tweet);
  }

  @override
  Widget build(BuildContext context) {
    // Parse the date of the creation of the tweet
    Map datetime = _parseDate(widget.tweet.createdAt);
    // current date and time
    DateTime now = DateTime.now();
    // time of the creation of the tweet
    var time = datetime['time'];

    // If the tweet was not posted today then show the time, the day and the month
    if ("${now.day}" != datetime['day']) {
      time = time + " " + datetime['day'] + " " + datetime['month'];
    }

    // If the tweet was not posted in the current year then add the year to the time
    if ("${now.day}" != datetime['year']) {
      time = time + " " + datetime['year'];
    }

    // normal card the displays essential information about a tweet
    var tweetCard = Column(
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
                        Text(name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.fade),
                        Flexible(
                          child: Text(" @" + userName,
                              style: TextStyle(color: Colors.grey),
                              overflow: TextOverflow.fade),
                        ),
                        Expanded(
                            child: Text(
                                datetime['time'].toString().substring(0, 5),
                                overflow: TextOverflow.fade))
                      ],
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 3.0),
                        child: Linkify(
                          text: text,
                          humanize: true,
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              throw 'Could not launch $link';
                            }
                          },
                        )),
                    Column(children: _getTweetImages()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ReplyWidget(userName: name, id: widget.tweet.idStr),
                        RetweetWidget(
                            isRetweeted: retweeted,
                            retweetCount: retweetCount,
                            id: widget.tweet.idStr),
                        FavoriteWidget(
                            isFavorited: favorited,
                            favoriteCount: favoriteCount,
                            id: widget.tweet.idStr),
                      ],
                    )
                  ],
                ))
              ]),
        ),
        Divider(height: 5)
      ],
    );

    // detail card show more information then the normal card
    var tweetCardDetails = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        isRetweeted(hasRetweeted, widget.tweet.user['name']),
        Row(
          children: <Widget>[
            Container(
              child: GestureDetector(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: image,
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return Profile(user: widget.tweet.user);
                  }));
                },
              ),
              margin: EdgeInsets.all(10),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("@" + userName,
                      style: TextStyle(color: Colors.grey),
                      overflow: TextOverflow.fade),
                  Text(
                      "${datetime['day']} ${datetime['month']} ${datetime['year']} at ${datetime['time']}",
                      style: TextStyle(color: Colors.grey),
                      overflow: TextOverflow.fade),
                ],
              ),
            ),
          ],
        ),
        Container(
            margin: EdgeInsets.only(bottom: 8.0),
            child:
                // Text(text)
                Linkify(
              text: text,
              humanize: true,
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
            )),
        Column(children: _getTweetImages()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ReplyWidget(userName: name, id: widget.tweet.idStr),
            RetweetWidget(
                isRetweeted: retweeted,
                retweetCount: retweetCount,
                id: widget.tweet.idStr),
            FavoriteWidget(
                isFavorited: favorited,
                favoriteCount: favoriteCount,
                id: widget.tweet.idStr),
          ],
        ),
        Divider(height: 5)
      ],
    );
    // Depending on the variable type a normal or detail card is returned
    var card = tweetCard;
    if (widget.type == TweetCard.detail) card = tweetCardDetails;
    return Container(margin: EdgeInsets.symmetric(horizontal: 15), child: card);
  }

  /// Adds Retweeted on to of the tweet
  Widget isRetweeted(ret, name) {
    if (ret)
      return Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Text(name + " Retweeted",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
    // If is not a retweet, then returns an empty widget that not occupy space
    return Container();
  }

  /// Retrieves images, gifs, video from the tweet
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

  /// Parse the data of a tweet and it assigned to the corrisponding variables
  getData(Tweet tweet) {
    if (tweet.extendedEntities != null) {
      List<dynamic> result;
      if (tweet.retweetedStatus == null)
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
    hasRetweeted = false;
    if (tweet.retweetedStatus != null) {
      tweet = Tweet.fromJson(tweet.retweetedStatus);
      hasRetweeted = true;
    }
    favorited = tweet.favorited;
    retweeted = tweet.retweeted;
    createdAt = tweet.createdAt;
    userName = tweet.user['screen_name'];
    name = tweet.user['name'];
    image = tweet.user['profile_image_url_https']
        .replaceAll(new RegExp(r'normal'), '200x200');
    retweetCount = tweet.retweetCount;
    favoriteCount = tweet.favoriteCount;
    text = tweet.text;
    if (tweet.entities != null) {
      List<dynamic> urlls = tweet.entities['urls'];
      urlls.forEach((u) {
        if (u['expanded_url'].contains("twitter")) {
          text = text.replaceAll(u['url'], "");
        }
      });
    }
  }

  /// Parse the datetime to useful information
  Map _parseDate(data) {
    var datetime = data.split(' ');
    var month, monthNum;
    switch (datetime[1]) {
      case "Jan":
        month = "January";
        monthNum = 1;
        break;
      case "Feb":
        month = "February";
        monthNum = 2;
        break;
      case "Mar":
        month = "March";
        monthNum = 3;
        break;
      case "Apr":
        month = "April";
        monthNum = 4;
        break;
      case "May":
        month = "May";
        monthNum = 5;
        break;
      case "Jun":
        month = "June";
        monthNum = 6;
        break;
      case "Jul":
        month = "July";
        monthNum = 7;
        break;
      case "Aug":
        month = "August";
        monthNum = 8;
        break;
      case "Sep":
        month = "September";
        monthNum = 9;
        break;
      case "Oct":
        month = "October";
        monthNum = 10;
        break;
      case "Nov":
        month = "November";
        monthNum = 11;
        break;
      case "Dec":
        month = "December";
        monthNum = 12;
        break;
    }
    Map<String, String> dt = new Map();
    dt['time'] = datetime[3];
    dt['day'] = datetime[2];
    dt['month'] = month;
    dt['monthNum'] = "${monthNum}";
    dt['year'] = datetime[5];
    return dt;
  }
}
