import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

class NewTweet extends StatefulWidget {
  var client;

  NewTweet({Key, key, @required this.client}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewTweetState();
}

class NewTweetState extends State<NewTweet> {
  var tweetTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Tweet", style: TextStyle(color: Colors.white)),
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
    tweet['status'] = tweetTextFieldController.text.toString();
    Fluttertoast.showToast(
        msg: "Tweeting...",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 2,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
    widget.client
        .post('https://api.twitter.com/1.1/statuses/update.json', body: tweet);
    Navigator.of(context).pop();
  }
}
