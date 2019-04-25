import 'dart:convert';

import 'package:cheep_for_twitter/pages/tweet_details.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card4.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  var client;
  var user;

  Profile({Key, key, @required this.client, @required this.user})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  Future<dynamic> _loadUserTime;
  List<Widget> _cachedTweets;

  @override
  void initState() {
    _loadUserTime = _getUserTimeline(widget.client);
    _cachedTweets = List<Widget>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.user;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
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
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                child: Container(
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
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
                                      .replaceAll(
                                          new RegExp(r'normal'), '200x200'),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text("@" + data['screen_name']),
                              Text(data['name'],
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(data['followers_count'].toString() +
                                  " Followers"),
                              Text(data['friends_count'].toString() +
                                  " Following")
                            ])
                      ],
                    )),
                  ),
                ),
              ],
            ))),
            Container(
                child: FutureBuilder(
              future: _loadUserTime,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> userTweets = json.decode(snapshot.data.body);

                  List<Widget> list = new List<Widget>();
                  userTweets.forEach((tweet) {
                    var t = Tweet.fromJson(tweet);
                    TweetCard r = TweetCard(tweet: t, client: widget.client);
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
                  return new Column(children: _cachedTweets);
                } else
                  return Container(child: CircularProgressIndicator());
              },
            ))
          ],
        ),
      ),
    );
  }

  Future<dynamic> _getUserTimeline(client) async {
    return await client.get(
        'https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&screen_name=' +
            widget.user['screen_name']);
  }
}
