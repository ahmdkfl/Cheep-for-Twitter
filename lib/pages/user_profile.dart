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

  @override
  void initState() {
    _loadUserTime = _getUserTimeline(widget.client);
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
                  return Column(children: <Widget>[CircularProgressIndicator()]);
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
                userTweets.forEach((tweet){
                  var t = Tweet.fromJson(tweet);
                  TweetCard r = TweetCard(tweet:t);
                  list.add(
                    GestureDetector(child: r,
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_){
                          return TweetDetails(tweet: t);
                        }));
                      },
                    )
                  );
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
