import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:cheep_for_twitter/twitterapi.dart';

/// Screen for a new tweet
/// It has a textfield and tweet button
/// The text from the textfield is sumbitted through the _sendTweet() method
/// when the tweet button is pressed
class NewTweet extends StatefulWidget {
  // Id of the tweet the reply is directed to
  String replyId;
  // Username of the user that tweet is directed to
  String username;

  NewTweet({Key, key, this.replyId, this.username}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewTweetState();
}

class NewTweetState extends State<NewTweet> {
  // Controls the behaviour of the textfield
  var tweetTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Set the title of the screnn based on whether or not
    // the username was passed
    var title;
    if (widget.username != null ?? "")
      title = "Reply to " + widget.username;
    else
      title = "New Tweet";

    return Scaffold(
      appBar: AppBar(
        // Titile of the screen
        title: Text(title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Text field where the tweet is written
            TextField(
                controller: tweetTextFieldController,
                maxLength: 280,
                decoration: InputDecoration(border: OutlineInputBorder())),
            // Tweet button
            FlatButton(
              child: Text("Tweet", style: TextStyle(color: Colors.white)),
              color: Colors.blue,
              // When the button is pressed calls _sendTweet function
              onPressed: _sendTweet,
            )
          ],
        ),
      ),
    );
  }

  /// Post a tweet
  /// If replyIs exist then the tweet is a reply
  /// If it does not, then it is a normal tweet
  _sendTweet() {
    // body in client.post requires a Map as parameter,
    // thus the replyId is put into one if it exist along with the message marked by status
    var tweet = new Map();
    var message = "Tweeting...";
    tweet['status'] = tweetTextFieldController.text.toString();
    if (widget.replyId != null ?? "") {
      tweet['in_reply_to_status_id'] = widget.replyId;
      tweet['status'] = "@" +
          widget.username +
          " " +
          tweetTextFieldController.text.toString();
      message = "Replying...";
    }
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 2,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
    // Retrieve the static instance of the client (Singleton)
    var client = Twitterapi().getClient();
    client.post('https://api.twitter.com/1.1/statuses/update.json',
        body: tweet);
    // Go to the previous screen
    Navigator.of(context).pop();
  }
}
