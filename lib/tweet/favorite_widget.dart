
import 'package:flutter/material.dart';


class FavoriteWidget extends StatefulWidget {

  var favorite, fcount;

  FavoriteWidget(fa, fc){
    favorite = fa;
    fcount = fc;
  }

  @override
  State<StatefulWidget> createState() => _FavoriteWidgetState(favorite, fcount);

}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  bool _isFavorited;
  int _favoriteCount;

  _FavoriteWidgetState(fa, fc){
    _isFavorited = fa;
    _favoriteCount = fc;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: IconButton(
            icon: (_isFavorited? Icon(Icons.favorite): Icon(Icons.favorite_border)),
            color: Colors.red,
            onPressed: _toggleFavorite,
          )
        ),
        SizedBox(
          width: 40,
          child: Container(
            child: Text('$_favoriteCount'),
          ),
        ),
      ],
    );
  }

  _toggleFavorite(){
    setState(() {
     if (_isFavorited) {
        _favoriteCount -= 1;
        _isFavorited = false;
      } else {
        _favoriteCount += 1;
        _isFavorited = true;
      } 
    });
  }

}