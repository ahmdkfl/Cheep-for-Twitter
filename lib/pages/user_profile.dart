import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card4.dart';
import 'package:cheep_for_twitter/pages/tweet_details.dart';

class UserProfile extends StatefulWidget {

  var client;

  UserProfile({Key, key, @required this.client}):super(key: key);

  @override
  State<StatefulWidget> createState() => UserProfileState();
  
}

class UserProfileState extends State<UserProfile> with AutomaticKeepAliveClientMixin {

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
    return ListView(shrinkWrap: true,
      children: <Widget>[
        Container(
          child: FutureBuilder(
            future: _getUserInfo(widget.client),
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
                  return Center(child:CircularProgressIndicator());
            },
          ),
        ),
        Container(child:
          FutureBuilder(
            future: _loadUserTime,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                List<dynamic> userTweets = json.decode(snapshot.data.body);

                List<Widget> list = new List<Widget>();
                if(_cachedTweets.isEmpty){
                  userTweets.forEach((tweet){
                    var t = Tweet.fromJson(tweet);
                    TweetCard r = TweetCard(tweet:t, client: widget.client);
                    list.add(
                      GestureDetector(child: r,
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_){
                            return TweetDetails(tweet: t);
                          }));
                        },
                      )
                    );
                  });
                  _cachedTweets = list;
                  }
                return new Column(children: _cachedTweets);
                }
              else
                return Center(child:CircularProgressIndicator());
            },
          )
        )
      ],
    );
  }
  
  @override
  bool get wantKeepAlive => true;

  Future<dynamic> _getUserInfo(client) async {
    return await client.get('https://api.twitter.com/1.1/account/verify_credentials.json');
  }

  Future<dynamic> _getUserTimeline(client) async {
    return await client.get('https://api.twitter.com/1.1/statuses/user_timeline.json');
  }
  
}
