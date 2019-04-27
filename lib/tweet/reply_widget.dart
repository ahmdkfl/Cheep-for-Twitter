import 'package:flutter/material.dart';
import 'package:cheep_for_twitter/pages/new_tweet.dart';

class ReplyWidget extends StatefulWidget {
  var isReplied, userName, id;

  ReplyWidget({Key key, @required this.isReplied, this.id, this.userName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            child: IconButton(
          icon: Icon(Icons.reply),
          iconSize: 18,
          color: (widget.isReplied ? Colors.blue : Colors.grey),
          onPressed: _toggleReply,
        )),
      ],
    );
  }

  _toggleReply() {
    setState(() {
      if (widget.isReplied) {
        widget.isReplied = false;
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return NewTweet(replyId: widget.id, username: widget.userName);
        }));
        widget.isReplied = true;
      }
    });
  }
}
