import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

/// Follow Button
class FollowWidget extends StatefulWidget {
  // id of the user to follow
  var id;

  FollowWidget({Key key, @required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FollowWidgetState();
}

/// Stateful Widget for the Follow widget
class _FollowWidgetState extends State<FollowWidget> {
  // authUserId is the authenticating user id
  // Because there is need to check whether or not the user is currenlty followed
  // and followed is set to false at the moment
  var authUserId, followed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          // User info of the authenticating user
          future: _getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data = json.decode(snapshot.data.body);
              authUserId = data['id_str'];
              return FutureBuilder(
                  future: _friend(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> friendship =
                          json.decode(snapshot.data.body);
                      // Check the if the user is followed or not
                      followed =
                          friendship['relationship']['source']['following'];
                      return Container(
                          child: FlatButton(
                        color: followed ? Colors.red : Colors.blue,
                        // if followed is true, it shows the Follow text
                        // otherwise the Unfollow text
                        child: Text(
                          followed ? "Unfollow" : "Follow",
                          style: TextStyle(color: Colors.white),
                        ),
                        // Toggles the following
                        onPressed: _toggleFollow,
                      ));
                    } else
                      return Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                  });
            } else
              return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
          }),
    );
  }

  /// Toggle the favorite icon and change the count of the Follow tweet
  _toggleFollow() {
    setState(() {
      if (followed)
        _unfollow();
      else
        _follow();
    });
  }

  /// Follow a user
  /// If followed is false, then follow the user
  Future<dynamic> _follow() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['user_id'] = widget.id;
    return await client.post(
        'https://api.twitter.com/1.1/friendships/create.json',
        body: body);
  }

  /// Unfollow a user
  /// If followed is true, then unfollow the user
  Future<dynamic> _unfollow() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['user_id'] = widget.id;
    return await client.post(
        'https://api.twitter.com/1.1/friendships/destroy.json',
        body: body);
  }

  /// Check the relationship between the authenticating user and the user
  Future<dynamic> _friend() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['source_id'] = authUserId;
    body['target_id'] = widget.id;
    return await client.get(
        'https://api.twitter.com/1.1/friendships/show.json?source_id=' +
            body['source_id'] +
            "&target_id=" +
            body['target_id']);
  }

  /// Retrieves information about the authenticating user
  Future<dynamic> _getUserInfo() async {
    var client = Twitterapi().getClient();
    return await client
        .get('https://api.twitter.com/1.1/account/verify_credentials.json');
  }
}
