
import 'package:flutter/material.dart';


class ReplyWidget extends StatefulWidget {

  var isReplied, replyCount;

  ReplyWidget({Key key, @required this.isReplied, @required this.replyCount}):super(key: key);

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
          )
        ),
        SizedBox(
          child: Container(
            child: Text('${widget.replyCount}',overflow: TextOverflow.fade),
          ),
        ),
      ],
    );
  }

  _toggleReply(){
    setState(() {
     if (widget.isReplied) {
        widget.replyCount -= 1;
        widget.isReplied = false;
      } else {
        widget.replyCount += 1;
        widget.isReplied = true;
      } 
    });
  }

}