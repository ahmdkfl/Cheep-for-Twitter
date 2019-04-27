
import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';

/// Favourite icon
/// 
/// Contains the count for the favourite tweet and the if it is favourited by the user
class FavoriteWidget extends StatefulWidget {

  var isFavorited, favoriteCount, id;

  FavoriteWidget({Key key, @required this.isFavorited, @required this.favoriteCount, @required this.id}):super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoriteWidgetState();

}

/// Stateful Widget for the Favourite widget
class _FavoriteWidgetState extends State<FavoriteWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Favorite icon
        Container(
          child: IconButton(
            // Display empty or favourite icon if favourite is true or false
            icon: (widget.isFavorited? Icon(Icons.favorite): Icon(Icons.favorite_border)),
            iconSize: 18,
            color: Colors.red,
            onPressed: _toggleFavorite,
          )
        ),
        // Count of the favourite tweet
        SizedBox(
          child: Container(
            child: Text('${widget.favoriteCount}',overflow: TextOverflow.fade),
          ),
        ),
      ],
    );
  }

  /// Toggle the favorite icon and change the count of the favourite tweet
  _toggleFavorite(){
    setState(() {
      // Change the favourite count and the favourite value whether the tweet is liked or not
      if (widget.isFavorited) {
        _unfavoriteTweet();
        widget.favoriteCount -= 1;
        widget.isFavorited = false;
      } else {
        _favoriteTweet();
        widget.favoriteCount += 1;
        widget.isFavorited = true;
      } 
    });
  }

  Future<dynamic> _favoriteTweet() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['id'] = widget.id;
    return await client.post(
        'https://api.twitter.com/1.1/favorites/create.json', body: body);
  }

  Future<dynamic> _unfavoriteTweet() async {
    var client = Twitterapi().getClient();
    Map<String, String> body = new Map();
    body['id'] = widget.id;
    return await client.post(
        'https://api.twitter.com/1.1/favorites/destroy.json', body: body);
  }

}