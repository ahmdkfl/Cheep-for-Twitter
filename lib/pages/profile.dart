import 'dart:async';
import 'dart:convert';

import 'package:cheep_for_twitter/pages/tweet_details.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tweet/follow_widget.dart';

class Profile extends StatefulWidget {
  var user;

  Profile({Key, key, @required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  Future<dynamic> _loadUserTime;
  List<Widget> _cachedTweets;

  @override
  void initState() {
    super.initState();
    _loadUserTime = _getUserTimeline();
    _cachedTweets = List<Widget>();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.user;

    Map datetime = _parseDate(data['created_at']);

    var profileCard = Card(
      child: Padding(
        padding: EdgeInsets.all(9),
        child: Center(
            child: Column(
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: data['profile_image_url']
                          .replaceAll(new RegExp(r'normal'), '200x200'),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(data['name'],
                            style: new TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                            child: SizedBox(
                                height: 15,
                                width: 15,
                                child: data['verified']
                                    ? IconButton(
                                        icon: Icon(Icons.verified_user))
                                    : Container()))
                      ]),
                  Text("@" + data['screen_name']),
                ]),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(data['description']),
                ))
              ],
            ),
            Container(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:Container()
                  // Text("Joined " + datetime['month'] + " " + datetime['year']),
            )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(data['followers_count'].toString() + " Followers"),
                  Text(data['friends_count'].toString() + " Following")
                ]),
            FollowWidget(id: data['id_str'])
          ],
        )),
      ),
    );
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(data['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: CachedNetworkImage(
                    imageUrl: data['profile_banner_url'],
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  )),
            ),
          ];
        },
        body: Column(
          // shrinkWrap: true,
          children: <Widget>[
            FutureBuilder(
              future: _loadUserTime,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> userTweets = json.decode(snapshot.data.body);

                  List<Widget> list = new List<Widget>();
                  list.add(profileCard);
                  userTweets.forEach((tweet) {
                    var t = Tweet.fromJson(tweet);
                    TweetCard r = TweetCard(tweet: t);
                    list.add(GestureDetector(
                      child: r,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return TweetDetails(tweet: t);
                        }));
                      },
                    ));
                  });
                  _cachedTweets = list;
                  return Expanded(child:
                      StreamBuilder<Object>(builder: (context, snapshot) {
                    return ListView(children: _cachedTweets, shrinkWrap: true);
                  }));
                } else
                  return Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator());
              },
            )
          ],
        ),
      ),
    );
  }

  /// Returns an a list of tweets as a JSON file from the user timeline
  Future<dynamic> _getUserTimeline() async {
    var client = Twitterapi().getClient();
    return await client.get(
        'https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&screen_name=' +
            widget.user['screen_name']);
  }

  /// Parse the datetime to useful information
  Map _parseDate(data) {
    var datetime = data.split(' ');
    var month;
    switch (datetime[1]) {
      case "Jan":
        month = "January";
        break;
      case "Feb":
        month = "February";
        break;
      case "Mar":
        month = "March";
        break;
      case "Apr":
        month = "April";
        break;
      case "May":
        month = "May";
        break;
      case "June":
        month = "June";
        break;
      case "July":
        month = "July";
        break;
      case "Aug":
        month = "August";
        break;
      case "Sept":
        month = "September";
        break;
      case "Oct":
        month = "October";
        break;
      case "Nov":
        month = "November";
        break;
      case "Dec":
        month = "December";
        break;
    }
    Map<String, String> dt = new Map();
    dt['month'] = month;
    dt['day'] = datetime[2];
    dt['year'] = datetime[5];
    return dt;
  }
}
