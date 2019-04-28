import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

// Reweets a tweet
class RetweetWidget extends StatefulWidget {
  // isRetweeted if the tweet is retweeted or not
  // retweetCount the number of the times the tweet is retweeted
  // id of the tweet
  var isRetweeted, retweetCount, id;

  RetweetWidget(
      {Key key,
      @required this.isRetweeted,
      @required this.retweetCount,
      this.id})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RetweetWidgetState();
}

class _RetweetWidgetState extends State<RetweetWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            // Retweet icon
            child: IconButton(
          icon: Icon(Icons.repeat),
          color: (widget.isRetweeted ? Colors.blue : Colors.grey),
          iconSize: 18,
          onPressed: _toggleRetweet,
        )),
        // Number of the retweets
        SizedBox(
          child: Container(
            child: Text('${widget.retweetCount}', overflow: TextOverflow.fade),
          ),
        ),
      ],
    );
  }

  /// Retweets a tweet or unretweets a tweet
  _toggleRetweet() {
    setState(() {
      if (widget.isRetweeted) {
        // unretweet a tweet
        _unretweet();
        widget.retweetCount -= 1;
        widget.isRetweeted = false;
      } else {
        // retweets a tweet
        _retweet();
        widget.retweetCount += 1;
        widget.isRetweeted = true;
      }
    });
  }

  // Retweets a tweet
  Future<dynamic> _retweet() async {
    var client = Twitterapi().getClient();
    return await client.post(
        'https://api.twitter.com/1.1/statuses/retweet/' + widget.id + '.json');
  }

  // Unretweets a tweet
  Future<dynamic> _unretweet() async {
    var client = Twitterapi().getClient();
    return await client.post('https://api.twitter.com/1.1/statuses/unretweet/' +
        widget.id +
        '.json');
  }
}
