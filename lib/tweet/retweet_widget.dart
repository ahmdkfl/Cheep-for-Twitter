
import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

class RetweetWidget extends StatefulWidget {

  var isRetweeted, retweetCount, id;

  RetweetWidget({Key key, @required this.isRetweeted, @required this.retweetCount, this.id}):super(key: key);

  @override
  State<StatefulWidget> createState() => _RetweetWidgetState();

}

class _RetweetWidgetState extends State<RetweetWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: IconButton(
            icon: Icon(Icons.repeat),
            color: (widget.isRetweeted ? Colors.blue : Colors.grey),
            iconSize: 18,
            onPressed: _toggleRetweet,
          )
        ),
        SizedBox(
          child: Container(
            child: Text('${widget.retweetCount}', overflow: TextOverflow.fade),
          ),
        ),
      ],
    );
  }

  _toggleRetweet(){
    setState(() {
     if (widget.isRetweeted) {
        _unretweet();
        widget.retweetCount -= 1;
        widget.isRetweeted = false;
      } else {
        _retweet();
        widget.retweetCount += 1;
        widget.isRetweeted = true;
      } 
    });
  }
  
  Future<dynamic> _retweet() async {
    var client = Twitterapi().getClient();
    return await client.post(
        'https://api.twitter.com/1.1/statuses/retweet/'+widget.id+'.json');
  }

  Future<dynamic> _unretweet() async {
    var client = Twitterapi().getClient();
    return await client.post(
        'https://api.twitter.com/1.1/statuses/unretweet/'+widget.id+'.json');
  }

}