import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tweet.dart';
import 'package:cheep_for_twitter/tweet_card.dart';

class UserProfile extends StatefulWidget {

  var _client;

  UserProfile(client){
    _client = client;
  }

  @override
  State<StatefulWidget> createState() => UserProfileState(_client);
  
}

class UserProfileState extends State<UserProfile> {

  var _client;

  UserProfileState(c){
    _client = c;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true,
    children: <Widget>[
      Container(
        child: FutureBuilder(
          future: _getUserInfo(_client),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              Map<String, dynamic> data = json.decode(snapshot.data.body);
              return Container(child:
                Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(child:
                      Padding(padding: EdgeInsets.all(9),child:
                        Center(
                          child:Column(children: <Widget>[
                            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                              ClipOval(
                              child: Image.network(
                                  data['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200'),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Text("@"+data['screen_name']),
                            Text(data['name'], style: new TextStyle(fontWeight: FontWeight.bold)),
                              ]
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                              Text(data['followers_count'].toString()+" Followers"),
                              Text(data['friends_count'].toString()+ " Following")
                              ]
                            )
                            ],)
                          ),
                        ),
                      ),
                    ],
                  )
                );
              }
              else
                return Column(children: <Widget>[CircularProgressIndicator()]);
          },
        ),
      ),
      Container(child:
        FutureBuilder(
          future: _getUserTimeline(_client),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              List<dynamic> userTweets = json.decode(snapshot.data.body);

              List<Widget> list = new List<Widget>();
              userTweets.forEach((tweet){
                var t = Tweet.fromJson(tweet);
                print(tweet);
                TweetCard r = TweetCard.fromTweet(t);
                list.add(r);
                // list.add(Text(tweet.toString()));
              });
              return new Column(children: list);
              }
            else
              return Column(children: <Widget>[CircularProgressIndicator()]);
          },
        )
      )
    ],
  );;
  }

  Future<dynamic> _getUserInfo(client){
  return client.get('https://api.twitter.com/1.1/account/verify_credentials.json').then((res) {
      return res;
  });
}

  Future<dynamic> _getUserTimeline(client){
    return client.get('https://api.twitter.com/1.1/statuses/user_timeline.json').then((res) {
        return res;
    });
  }
  
}