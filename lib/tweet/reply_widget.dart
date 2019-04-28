import 'package:flutter/material.dart';
import 'package:cheep_for_twitter/pages/new_tweet.dart';

/// Reply button
class ReplyWidget extends StatefulWidget {
  // username of the user the reply is directed to
  // and id of the tweet the reply is directed to
  var userName, id;

  ReplyWidget({Key key, this.id, this.userName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            // Reply icon
            child: IconButton(
          icon: Icon(Icons.reply),
          iconSize: 18,
          color: Colors.grey,
          onPressed: _reply,
        )),
      ],
    );
  }

  /// Shows a reply screen
  _reply() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return NewTweet(replyId: widget.id, username: widget.userName);
    }));
  }
}
