import 'dart:async';
import 'dart:convert';

import 'package:cheep_for_twitter/pages/tweet_details.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tweet/follow_widget.dart';

/// Screen that displays the profile of a user
class Profile extends StatefulWidget {
  // the user Map variables that has all the user informations
  var user;
  // true if the user is the authenticating user
  bool isAuthUser;

  Profile({Key, key, @required this.user, this.isAuthUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // if the isAuthUser is not true, then false is assigned
    if (isAuthUser == null) isAuthUser = false;
    return ProfileState();
  }
}

class ProfileState extends State<Profile> {
  // Future that contains the information about the user timeline
  Future<dynamic> _loadUserTime;

  @override
  void initState() {
    super.initState();
    // Assign the method that gives back data from the future to this variables
    _loadUserTime = _getUserTimeline();
  }

  @override
  Widget build(BuildContext context) {
    // data contains the user map data
    Map<String, dynamic> data = widget.user;
    // Date and time of the creation of the tweet
    Map datetime = _parseDate(data['created_at']);

    // Profile card
    var profileCard = Card(
      child: Padding(
        padding: EdgeInsets.all(9),
        child: Center(
            child: Column(
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // It is the rounded image that contains the user profile image =
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: data['profile_image_url']
                          .replaceAll(new RegExp(r'normal'), '200x200'),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.person),
                      height: 100,
                      width: 100,
                      // Rounds the image
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Displays the verified sign is the user is verified by Twitter
                  Container(
                      child: data['verified']
                          ? IconButton(icon: Icon(Icons.verified_user))
                          : Container()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Name of the user
                        Text(data['name'],
                            style: new TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                  // Username of the user
                  Text("@" + data['screen_name']),
                ]),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Description of the profile of the user
                  child: Text(data['description']),
                ))
              ],
            ),
            Container(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              // Shows when the user is registered on Twitter
              child: Text("Joined ${datetime['month']} ${datetime['year']}"),
            )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Number of users the user is following
                  Text(data['followers_count'].toString() + " Followers"),
                  // Number of users the user is followed by
                  Text(data['friends_count'].toString() + " Following")
                ]),
            // Shows the follow button only if the user is not followed by the authenticating user
            (widget.isAuthUser ? Container() : FollowWidget(id: data['id_str']))
          ],
        )),
      ),
    );

    // Top image of the user
    var bannerImage = CachedNetworkImage(
      imageUrl: data['profile_banner_url'],
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.cover,
    );

    // List of tweets that that specific user has on the timeline
    var profile = FutureBuilder(
      future: _loadUserTime,
      builder: (context, snapshot) {
        // If the data are retieved
        if (snapshot.hasData) {
          List<dynamic> userTweets = json.decode(snapshot.data.body);

          List<Widget> list = new List<Widget>();
          // First the profileCard is added to the list
          list.add(profileCard);
          // then all the tweets are added
          userTweets.forEach((tweet) {
            var t = Tweet.fromJson(tweet);
            TweetCard r = TweetCard(tweet: t);
            list.add(GestureDetector(
              child: r,
              onTap: () {
                // When the user taps a tweets a new screen
                // that shows the details about the tweets and
                // the replies
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return TweetDetails(tweet: t);
                }));
              },
            ));
          });
          // return the list
          return Expanded(
              child: StreamBuilder<Object>(builder: (context, snapshot) {
            return ListView(children: list, shrinkWrap: true);
          }));
        } else
          // if the data are not retrieved then show the loading sign
          return Align(
              alignment: Alignment.center, child: CircularProgressIndicator());
      },
    );

    return Scaffold(
      body: NestedScrollView(
        // Bar that shrinks and expands and that contains the banner image
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: false,
              snap: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  // Name of the user
                  title: Text(data['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: bannerImage),
            ),
          ];
        },
        // Body contains the profile card and all the tweets
        body: Column(
          children: <Widget>[profile],
        ),
      ),
    );
  }

  /// Returns an a list of tweets as a JSON file from the user timeline
  Future<dynamic> _getUserTimeline() async {
    var client = Twitterapi().getClient();
    return await client.get(
        'https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&tweet_mode=expanded&screen_name=' +
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
      case "Jun":
        month = "June";
        break;
      case "Jul":
        month = "July";
        break;
      case "Aug":
        month = "August";
        break;
      case "Sep":
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
    dt['day'] = datetime[2];
    dt['month'] = month;
    dt['year'] = datetime[5];
    return dt;
  }
}
