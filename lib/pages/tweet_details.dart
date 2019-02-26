import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/tweet_card4.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'dart:convert';

class TweetDetails extends StatelessWidget {

  final Tweet tweet;

  TweetDetails({Key key, @required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
      body: Column(children: <Widget>[
        TweetCard(tweet: tweet),
        Expanded(child:FutureBuilder(
          future: _loadReplies(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              var tweets = snapshot.data['statuses'];

              List<Widget> list = new List<Widget>();
              tweets.forEach((tweetItem){
                var t = Tweet.fromJson(tweetItem);
                if(tweetItem['in_reply_to_status_id_str']==tweet.idStr)
                list.add(
                  GestureDetector(
                    child: TweetCard(tweet:t),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return TweetDetails(tweet: t);
                      }));
                    },
                  )
                );
              });
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return list[index];
                },
              );
              }
            else
              return Column(children: <Widget>[CircularProgressIndicator()]);
          },
        ))
      ],)
    );
  }

  Future<dynamic> _getReplies(client, id, sinceId){
    return client.get('https://api.twitter.com/1.1/search/tweets.json?count=100&q='+id.toString()+"&since_id="+sinceId.toString()).then((res) {
        return res;
    });
  }

  Future<String> _getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cred = prefs.getString("credentials");
    return cred;
  }

  Future<Map<String, dynamic>> _loadReplies() {
    return _getCredentials().then((credentials){
      var r = credentials;
      var r2 = r.split('=');
      var r3 = r2[1].split('&');
      var oauth_token_sec=r2[2];
      var oauth_token=r3[0];
      var client = Twitterapi().getAuthorClient(oauth_token, oauth_token_sec);
      return _getReplies(client, tweet.user['screen_name'], tweet.idStr).then((result){
          Map<String, dynamic> data = json.decode(result.body);
          // var r = data['statuses'];
          // r.forEach((t){
          //   // print(t['text']);
          //   if(t['in_reply_to_status_id_str']==tweet.idStr)
          //     print(t['user']['screen_name']+";"+t['text']);
          // });
          // print(result.body);
          return data;
        });
    });
  }

}