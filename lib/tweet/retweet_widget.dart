
import 'package:flutter/material.dart';


class RetweetWidget extends StatefulWidget {

  var isRetweeted, retweetCount;

  RetweetWidget({Key key, @required this.isRetweeted, @required this.retweetCount}):super(key: key);

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
        widget.retweetCount -= 1;
        widget.isRetweeted = false;
      } else {
        widget.retweetCount += 1;
        widget.isRetweeted = true;
      } 
    });
  }

}