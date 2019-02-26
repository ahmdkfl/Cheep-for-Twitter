
import 'package:flutter/material.dart';


class FavoriteWidget extends StatefulWidget {

  var isFavorited, favoriteCount;

  FavoriteWidget({Key key, @required this.isFavorited, @required this.favoriteCount}):super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoriteWidgetState();

}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: IconButton(
            icon: (widget.isFavorited? Icon(Icons.favorite): Icon(Icons.favorite_border)),
            iconSize: 18,
            color: Colors.red,
            onPressed: _toggleFavorite,
          )
        ),
        SizedBox(
          child: Container(
            child: Text('${widget.favoriteCount}',overflow: TextOverflow.fade),
          ),
        ),
      ],
    );
  }

  _toggleFavorite(){
    setState(() {
     if (widget.isFavorited) {
        widget.favoriteCount -= 1;
        widget.isFavorited = false;
      } else {
        widget.favoriteCount += 1;
        widget.isFavorited = true;
      } 
    });
  }

}