
import 'package:flutter/material.dart';


class ReplyWidget extends StatefulWidget {

  var isReplied;

  ReplyWidget({Key key, @required this.isReplied}):super(key: key);

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
      ],
    );
  }

  _toggleReply(){
    setState(() {
     if (widget.isReplied) {
        widget.isReplied = false;
      } else {
        widget.isReplied = true;
      } 
    });
  }

}