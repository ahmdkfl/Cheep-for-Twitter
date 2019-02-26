
import 'package:flutter/material.dart';
import 'package:cheep_for_twitter/tweet/tweet.dart';
import 'package:cheep_for_twitter/tweet/favorite_widget.dart';
import 'package:cheep_for_twitter/tweet/retweet_widget.dart';
import 'package:cheep_for_twitter/tweet/reply_widget.dart';
import 'package:cheep_for_twitter/pages/link_page.dart';
import 'package:cheep_for_twitter/pages/image_zoom.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class TweetCard extends StatelessWidget {

  String image;
  String name;
  String userName;
  String text;
  List<String> images;
  bool favorited;
  bool retweeted;

  TweetCard({Key key, @required this.image, @required this.name, @required this.userName, @required this.text, this.images, @required this.favorited, @required this.retweeted}):super(key: key);

  @override
  Widget build(BuildContext context) {

    final tweetCard = new Container(
      margin: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3.0,
            offset: Offset(0.0, 2.0)
          )
        ]
      ),
    );

    return new Container(
      margin: const EdgeInsets.symmetric(
        vertical: 5.0
      ),
      child: Stack(
        children: <Widget>[
          tweetCard,
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(child: 
                      ClipOval(
                        child: Image.asset(
                          image,
                          height: 55,
                          width: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),                      
                        child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _isRetweeted(retweeted),
                              Row(children: <Widget>[
                                Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                                Text(" @"+userName, style: TextStyle(color: Colors.grey), overflow: TextOverflow.fade),
                              ],),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 3.0),
                                child: 
                                  Text(text,softWrap: true,),
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    child: ClipRRect(child:Image.asset(image,fit: BoxFit.contain),
                                    borderRadius: BorderRadius.circular(4.0),),
                                    width: double.infinity
                                  ),                                      
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ReplyWidget(isReplied: false, replyCount: 2),
                                  RetweetWidget(isRetweeted: retweeted, retweetCount: 0),
                                  FavoriteWidget(isFavorited: favorited, favoriteCount: 0),
                                  FavoriteWidget(isFavorited: true, favoriteCount: 13),
                                ],
                              )
                            ],
                        ),
                      )
                    )
                  ]
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _isRetweeted(ret){
    if(ret)
      return Text("Retweeted");
    return Container();
  }

}

