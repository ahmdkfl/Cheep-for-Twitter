import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:cheep_for_twitter/twitterapi.dart';

class NewTweet extends StatefulWidget {

  String replyId;
  String username;

  NewTweet({Key, key, this.replyId, @required this.username}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewTweetState();
}

class NewTweetState extends State<NewTweet> {
  var tweetTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var title;
    if(widget.username != null ?? "")
      title = "Reply to "+widget.username;
    else
      title = "New Tweet";
    print(widget.replyId);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextField(
                controller: tweetTextFieldController,
                maxLength: 280,
                decoration: InputDecoration(border: OutlineInputBorder())),
            FlatButton(
              child: Text("Tweet", style: TextStyle(color: Colors.white)),
              color: Colors.blue,
              onPressed: _sendTweet,
            )
          ],
        ),
      ),
    );
  }

  _sendTweet() {
    var tweet = new Map();
    tweet['status'] = "@"+widget.username+" "+tweetTextFieldController.text.toString();
    if(widget.replyId != null ?? "")
      tweet['in_reply_to_status_id'] = widget.replyId;
    Fluttertoast.showToast(
        msg: "Tweeting...",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 2,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
    var client = Twitterapi().getClient();
    client
        .post('https://api.twitter.com/1.1/statuses/update.json', body: tweet);
    Navigator.of(context).pop();
  }
}
