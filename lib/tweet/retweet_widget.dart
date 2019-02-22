
import 'package:flutter/material.dart';


class RetweetWidget extends StatefulWidget {

  var retweeted, rcount;

  RetweetWidget(re, rc){
    retweeted = re;
    rcount = rc;
  }

  @override
  State<StatefulWidget> createState() => _RetweetWidgetState(retweeted, rcount);

}

class _RetweetWidgetState extends State<RetweetWidget> {

  bool _isRetweeted;
  int _retweetCount;

  _RetweetWidgetState(re, rc){
    _isRetweeted = re;
    _retweetCount = rc;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: IconButton(
            icon: Icon(Icons.repeat),
            color: (_isRetweeted ? Colors.blue : Colors.grey),
            onPressed: _toggleFavorite,
          )
        ),
        SizedBox(
          width: 40,
          child: Container(
            child: Text('$_retweetCount'),
          ),
        ),
      ],
    );
  }

  _toggleFavorite(){
    setState(() {
     if (_isRetweeted) {
        _retweetCount -= 1;
        _isRetweeted = false;
      } else {
        _retweetCount += 1;
        _isRetweeted = true;
      } 
    });
  }

}