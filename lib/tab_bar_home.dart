import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/pages/profile.dart';
import 'package:cheep_for_twitter/pages/home_timeline.dart';
import 'package:cheep_for_twitter/pages/settings.dart';
import 'package:cheep_for_twitter/pages/new_tweet.dart';

class TabBarHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TabBarHomeState();
}

class _TabBarHomeState extends State<TabBarHome>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.perm_identity)),
              Tab(icon: Icon(Icons.settings)),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.lightBlueAccent,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.blue,
          ),
          body: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                    title: Text("Cheep for Twitter"),
                    floating: true,
                    pinned: true,
                    snap: false,
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          "Tweet",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return NewTweet();
                          }));
                        },
                      )
                    ])
              ];
            },
            body: TabBarView(
              children: [
                new Container(color: Colors.white, child: HomeTimeline()),
                new Container(
                    color: Colors.white,
                    child: FutureBuilder(
                        future: _getUserInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Map<String, dynamic> user =
                                json.decode(snapshot.data.body);
                            return Profile(user: user, isAuthUser: true);
                          } else
                            return Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator());
                        })),
                new Container(color: Colors.white, child: Settings())
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<dynamic> _getUserInfo() async {
    var client = Twitterapi().getClient();
    return await client
        .get('https://api.twitter.com/1.1/account/verify_credentials.json');
  }
}
