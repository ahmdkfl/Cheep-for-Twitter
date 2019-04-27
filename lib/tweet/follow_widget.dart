import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

/// Favourite icon
///
/// Contains the count for the favourite tweet and the if it is favourited by the user
class FollowWidget extends StatefulWidget {
  var id;

  FollowWidget({Key key, @required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FollowWidgetState();
}

/// Stateful Widget for the Favourite widget
class _FollowWidgetState extends State<FollowWidget> {
  var authUserId, followed = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          Map<String, dynamic> data = json.decode(snapshot.data.body);
          authUserId = data['id_str'];
          print(authUserId);
          return FutureBuilder(future: _friend(),builder: (context, snapshot){
            Map<String, dynamic> friendship = json.decode(snapshot.data.body);
            followed = friendship['relationship']['source']['following'];
            return Container(
                child: FlatButton(color: followed?Colors.red:Colors.blue,
              child: Text(followed ? "Unfollow" : "Follow",style: TextStyle(color: Colors.white),),
              onPressed: _toggleFollow,
            ));
          });
        });
  }

  /// Toggle the favorite icon and change the count of the favourite tweet
  _toggleFollow() {
    setState(() {
      if (followed)
        _unfollow();
      else
        _follow();
    });
  }

  Future<dynamic> _follow() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['user_id'] = widget.id;
    return await client.post(
        'https://api.twitter.com/1.1/friendships/create.json',
        body: body);
  }

  Future<dynamic> _unfollow() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['user_id'] = widget.id;
    return await client.post(
        'https://api.twitter.com/1.1/friendships/destroy.json',
        body: body);
  }

  Future<dynamic> _friend() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['source_id'] = authUserId;
    body['target_id'] = widget.id;
    return await client
        .get('https://api.twitter.com/1.1/friendships/show.json?source_id='+body['source_id']+"&target_id="+body['target_id']);
  }

  Future<dynamic> _getUserInfo() async {
    var client = Twitterapi().getClient();
    return await client
        .get('https://api.twitter.com/1.1/account/verify_credentials.json');
  }
}
